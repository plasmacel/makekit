/*
	MIT License

	Copyright (c) 2018 Celestin de Villa

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

#include <cstdlib>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <regex>
#include <string>
#include <sys/stat.h>
#include "argh.h"

static const std::string VERSION = "0.3.3";
static const std::string BUILD_DIR_PREFIX = "build.";
static const std::string DEFAULT_CONFIG = "Release";
static const std::string DEFAULT_TOOLCHAIN = "llvm.native";

std::string get_directory(const std::string& filepath)
{
	return filepath.substr(0, filepath.find_last_of("/\\"));
}

std::string get_extension(const std::string& filepath)
{
	return filepath.substr(filepath.find_last_of(".") + 1);
}

std::string get_filename(const std::string& filepath)
{
	return filepath.substr(filepath.find_last_of("/\\") + 1);
}

std::string get_filename_we(const std::string& filepath)
{
	return filepath.substr(filepath.find_last_of("/\\") + 1, filepath.find_last_of("."));
}

// macOS utils

std::string get_macos_app(const std::string& filepath)
{
	return filepath.substr(0, filepath.find_first_of("/\\", filepath.find_last_of(".app")));
}

std::string get_macos_app_name(const std::string& filepath)
{
	return get_filename(get_macos_app(filepath));
}

std::string get_app_name_we(const std::string& filepath)
{
	return get_filename_we(get_macos_app(filepath));
}

std::string get_macos_framework(const std::string& filepath)
{
	return filepath.substr(0, filepath.find_first_of("/\\", filepath.find_last_of(".framework")));
}

std::string get_macos_framework_name(const std::string& filepath)
{
	return get_filename(get_macos_framework(filepath));
}

std::string get_macos_framework_name_we(const std::string& filepath)
{
	return get_filename_we(get_macos_framework(filepath));
}

bool is_macos_app(const std::string& filepath)
{
	return filepath.find_first_of(".app") != std::string::npos;
}

bool is_macos_framework(const std::string& filepath)
{
	return filepath.find_first_of(".framework") != std::string::npos;
}

std::pair<std::string, std::string> get_directory_and_filename(const std::string& filepath)
{
	const size_t index = filepath.find_last_of("/\\");
	return { filepath.substr(0, index), filepath.substr(index + 1) };
}

std::string get_build_dir(const std::string& config)
{
	return BUILD_DIR_PREFIX + config;
}

std::string get_bundle_lib_dir(const std::string& executable)
{
	// Lib dir
	// Linux: bundle_dir/lib
	// macOS: bundle_dir/Contents/Frameworks
	// Windows: bundle_dir/bin

	// Bin dir
	// Linux: bundle_dir/bin
	// macOS: bundle_dir/Contents/MacOS
	// Windows: bundle_dir/bin

#if _WIN32
	return get_directory(executable);
#elif __APPLE__
	return get_directory(executable) + "/../Frameworks";
#else
	return get_directory(executable) + "/../lib";
#endif
}

FILE* open_pipe(const char* command, const char* mode)
{
#if _WIN32
	return _popen(command, mode);
#else
	return popen(command, mode);
#endif
}

int close_pipe(FILE* stream)
{
#if _WIN32
	return _pclose(stream);
#else
	return pclose(stream);
#endif
}

std::string exec(const std::string& cmd)
{
	if (cmd.empty()) return "";

	char buffer[128];
	std::string result;

	//std::array<char, 128> buffer;	
	//std::shared_ptr<FILE> pipe(_popen(cmd, "r"), _pclose);

	FILE* pipe = open_pipe(cmd.c_str(), "r");

	if (!pipe) throw std::runtime_error("popen() failed!");

	try
	{
		while (!feof(pipe))
		{
			if (std::fgets(buffer, 128, pipe) != nullptr)
				result += buffer;
		}
	}
	catch (...)
	{
		close_pipe(pipe);
		throw;
	}

	close_pipe(pipe);

	return result;
}

std::string get_env_var(const std::string& var)
{
	std::string value;

#ifdef _WIN32
	char* buf = nullptr;
	size_t n = 0;

	if ((_dupenv_s(&buf, &n, var.c_str()) == 0) && (buf != nullptr))
	{
		value.assign(buf, n - 1);
		std::free(buf);
	}
#else
	value = std::getenv(var.c_str());
#endif

	return value;
}

/*
std::string getenv_exec(const std::string& var)
{
#	ifdef _WIN32
	std::string cmdout = exec("echo %" + var + "%");
#	else
	std::string cmdout = exec("echo ${" + var + "}");
#	endif

	// remove trailing newline character
	return cmdout.substr(0, cmdout.find_first_of("\r\n"));
}
*/

void file_copy(const std::string& srcpath, const std::string& dstpath)
{
	std::ifstream src(srcpath, std::ios::binary);
	std::ofstream dst(dstpath, std::ios::binary);

	dst << src.rdbuf();
}

bool file_exists(const std::string &filepath)
{
	if (filepath.empty()) return false;
	struct stat buffer;
	return stat(filepath.c_str(), &buffer) != -1;
}

std::string make_directory(const std::string& path)
{
#if _WIN32
	return exec("@mkdir \"" + path + "\"");
#else
	return exec("mkdir -p \"" + path + "\"");
#endif
}

void query_syspaths(std::vector<std::string>& syspaths)
{
#if _WIN32
	syspaths = { get_env_var("SYSTEMROOT") + "\\System32", get_env_var("WINDIR") + "\\System32" };
#elif __APPLE__
	syspaths = { "/System/Library", "/usr/lib" };
#else
	syspaths = { "/lib", "/lib32", "/libx32", "/lib64", "/usr/lib", "/usr/lib32", "/usr/libx32", "/usr/lib64", "/usr/X11R6", "/usr/bin" };
#endif
}

struct runtime_dependency
{
	runtime_dependency(const std::string& filepath)
	:
		unresolved{filepath},
		resolved{},
		bundled{},
		system{false}
	{}

	bool resolve(const std::vector<std::string>& rpaths, const std::vector<std::string>& syspaths)
	{
#if _WIN32

		// Try to resolve the original path

		resolved = unresolved;
		if (file_exists(resolved)) return true;

		// Try to resolve by syspaths

		for (const std::string& syspath : syspaths)
		{
			resolved = unresolved;
			resolved.insert(0, syspath + "\\");

			if (file_exists(resolved)) return true;
		}

		// Try to resolve by rpaths

		for (const std::string& rpath : rpaths)
		{
			resolved = unresolved;
			resolved.insert(0, rpath + "\\");

			if (file_exists(resolved)) return true;
		}
#else

		const size_t rpath_substring_pos = unresolved.find("@rpath");

		if (rpath_substring_pos != std::string::npos)
		{
			// Try to resolve by syspaths

			for (const std::string& syspath : syspaths)
			{
				resolved = unresolved;
				resolved.replace(rpath_substring_pos, rpath_substring_pos + 6, syspath);

				if (file_exists(resolved)) return true;
			}

			// Try to resolve by rpaths

			for (const std::string& rpath : rpaths)
			{
				resolved = unresolved;
				resolved.replace(rpath_substring_pos, rpath_substring_pos + 6, rpath);

				if (file_exists(resolved)) return true;
			}
		}
		else
		{
			// Try to resolve the original path
			resolved = unresolved;
			if (file_exists(resolved)) return true;
		}
#endif

		resolved.clear();

		return false;
	}

	bool bundle(const std::string& target_dir)
	{
		if (!is_resolved()) return false;
		if (!file_exists(target_dir)) return false;

		bundled = target_dir + "/" + get_filename(resolved);

		file_copy(resolved, bundled);

		return true;
	}

	bool is_bundled() const
	{
		return !bundled.empty();
	}

	bool is_resolved() const
	{
		return !resolved.empty();
	}

	bool is_system() const
	{
#if _WIN32
		const std::string sysroot = std::regex_replace(get_env_var("SYSTEMROOT"), std::regex{R"(\\)"}, R"(\\)");
		const std::string windir = std::regex_replace(get_env_var("WINDIR"), std::regex{R"(\\)"}, R"(\\)");

		//std::cout << std::endl << sysroot << std::endl;

		std::regex regex{"^(?:" + sysroot + "[/\\\\]sys(?:tem|wow)|" + windir + "[/\\\\]sys(?:tem|wow)|(.*[/\\\\])*(?:msvc|api-ms-win-)[^/\\\\]+dll)", std::regex_constants::icase};
#elif __APPLE__
		std::regex regex{"^(/System/Library/|/usr/lib/)", std::regex_constants::icase};
#else
		std::regex regex{"^(/lib/|/lib32/|/libx32/|/lib64/|/usr/lib/|/usr/lib32/|/usr/libx32/|/usr/lib64/|/usr/X11R6/|/usr/bin/)", std::regex_constants::icase};
#endif

		return std::regex_search(resolved, regex);
		return system;
	}

	std::string unresolved;
	std::string resolved;
	std::string bundled;
	bool system;
};

struct system_commands
{
	std::string commands;

	system_commands& operator=(const std::string& str)
	{
		this->commands = str;
		return *this;
	}

	void append(const std::string& cmd)
	{
		std::string sep;

		if (!this->commands.empty())
		{
			sep = " && ";
		}

		this->commands += sep + cmd;
	}

	operator const char*() const
	{
		return this->commands.c_str();
	}

	operator const std::string&() const
	{
		return commands;
	}
};

inline void message(system_commands& cmd, const std::string& msg)
{
	cmd.append("echo " + msg);
}

inline void where_path(system_commands& cmd, const std::string& filename)
{
#ifdef _WIN32
	cmd.append("where " + filename);
#else
	cmd.append("which " + filename);
#endif
}

inline bool has_path(const std::string& filename)
{
#ifdef _WIN32
	std::system(std::string{"where /q \"" + filename + "\""}.c_str());
	return get_env_var("ERRORLEVEL") == "0";
#else
	std::system(std::string{"which " + filename}.c_str());
	return get_env_var("?") == "0";
#endif
}

#ifdef _WIN32
void add_set_environment_command(system_commands& cmd, const std::string& host_arch, const std::string& target_arch)
{
	std::string current_host_arch = get_env_var("VSCMD_ARG_HOST_ARCH");
	std::string current_target_arch = get_env_var("VSCMD_ARG_TGT_ARCH");

	/*
	std::cout << "Current host architecture: " << current_host_arch << std::endl;
	std::cout << "Current target architecture: " << current_target_arch << std::endl;

	std::cout << "New host architecture:" << host_arch << std::endl;
	std::cout << "New target architecture: " << target_arch << std::endl;
	*/

	if ((current_host_arch != host_arch) || (current_target_arch != target_arch))
	{
		//cmd.append("vswhere -nologo -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > vsdevcmd_dir.txt");
		//cmd.append("set /p VSDEVCMD_DIR=< vsdevcmd_dir.txt");
		//cmd.append("del vsdevcmd_dir.txt");
		//cmd.append("set VSCMD_ARG_no_logo=1");
		//cmd.append("call \"%VSDEVCMD_DIR%\\Common7\\Tools\\VsDevCmd.bat\" -arch=" +  target_arch + " -host_arch=" + host_arch);
		cmd.append("call vsdevcmd_proxy.bat -arch=" +  target_arch + " -host_arch=" + host_arch);
	}
}

inline void add_set_environment_command(system_commands& cmd, const std::string& arch)
{
	add_set_environment_command(cmd, arch, arch);
}
#endif

std::string read_file(const std::string& filename)
{
	std::ifstream file(filename);
	std::string str;

	if (!file.is_open())
	{
		std::cerr << "ERROR File cannot be opened: " << filename << std::endl;
		return str;
	}

	file.seekg(0, std::ios::end);
	str.reserve(file.tellg());
	file.seekg(0, std::ios::beg);

	str.assign((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());

	return str;
}

int configure(system_commands& cmd, std::string config, std::string toolchain)
{
	if (config.empty()) config = DEFAULT_CONFIG;
	if (toolchain.empty()) toolchain = DEFAULT_TOOLCHAIN;

	message(cmd, "Configuring " + config + " build.");

	// Compose terminal commands
	
	const std::string build_dir = get_build_dir(config);

	// Append set environment command (required on Windows only)

#ifdef _WIN32
	add_set_environment_command(cmd, "x64");
#endif

	// Append run CMake command

	std::string cmake_command = "cmake .";
	cmake_command += " -GNinja";
	cmake_command += " -B\"" + build_dir + "\"";
	cmake_command += " -DCMAKE_BUILD_TYPE=\"" + config + "\"";
#ifdef _WIN32
	cmake_command += " -DCMAKE_TOOLCHAIN_FILE=\"%MK_DIR%/cmake/toolchains/" + toolchain + ".toolchain.cmake\"";
#else
	cmake_command += " -DCMAKE_TOOLCHAIN_FILE=\"$MK_DIR/cmake/toolchains/" + toolchain + ".toolchain.cmake\"";
#endif

	cmd.append(cmake_command);

	return 0;
}

int refresh(system_commands& cmd, std::string config)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	message(cmd, "Refreshing " + config + " build.");

	// Compose terminal commands

	const std::string build_dir = get_build_dir(config);

	//#ifdef _WIN32
	//	cmd.append("if not exist \"" + build_dir + "/CMakeCache.txt\" ( echo " + config + " config cannot be found. )");
	//#else
	//	cmd.append("if [ ! -f \"" + build_dir + "/CMakeCache.txt\" ]; then echo " + config + " config cannot be found.; fi");
	//#endif

	// Append run CMake command

	std::string cmake_command = "cmake .";
	cmake_command += " -GNinja";
	cmake_command += " -B\"" + build_dir + "\"";
	cmake_command += " -DCMAKE_BUILD_TYPE=\"" + config + "\"";

	cmd.append(cmake_command);

	return 0;
}

int make(system_commands& cmd, std::string config, const std::string& toolchain, std::string target, const std::string& max_threads, bool configure_flag, bool refresh_flag)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	const std::string build_dir = get_build_dir(config);
	
	// Configure or refresh
	
	if (configure_flag)
	{
		if (configure(cmd, config, toolchain) != 0) return 1;
	}
	else
	{
		if (!toolchain.empty())
		{
			message(cmd, "Toolchain is ignored without the config (-C) flag.");
		}

		if (refresh_flag)
		{
			if (refresh(cmd, config)) return 1;
		}

		
#ifdef _WIN32
		add_set_environment_command(cmd, "x64");
#endif
	}

	// Append build commands

#if 0

	std::string ninja_status = read_file("mk_status.txt");
	
	if (!ninja_status.empty())
	{
#	ifdef _WIN32
		cmd.append("set \"NINJA_STATUS=" + ninja_status + " \"");
#	else
		cmd.append("export \"NINJA_STATUS=" + ninja_status + " \"");
#	endif
	}

#endif

	std::string ninja_command;

	if (target.back() == '^') // Compiling a single source
	{
		message(cmd, "Compiling " + target.substr(0, target.size() - 1) + " using " + config + " build.");
		ninja_command = "ninja -C \"" + build_dir + "\" \"../" + target + "\"";
	}
	else
	{
		ninja_command = "ninja -C \"" + build_dir + "\"";

		if (!target.empty())
		{
			message(cmd, "Building target " + target + " using " + config + " build.");
			ninja_command += " " + target;
		}
		else
		{
			message(cmd, "Building all targets using " + config + " build.");
		}

		if (!max_threads.empty() && (max_threads != "0"))
		{
			//message(cmd, "Maximum number of parallel build threads are limited to " + std::to_string(max_threads));
			ninja_command += " -j " + max_threads;
		}
	}

	cmd.append(ninja_command);

#	ifdef _WIN32
	cmd.append("if %ERRORLEVEL% == 0 ( echo Build succeeded. ) else ( echo Build failed. )");
#	else
	cmd.append("if [ $? -eq 0 ]; then echo Build succeeded.; else echo Build failed.; fi");
#	endif

	return 0;
}

int clean_config(system_commands& cmd, const std::string& config)
{
	if (config.empty()) // Clean CMakeCache.txt of ALL build configurations
	{
		message(cmd, "Cleaning the configuration of all builds.");

#	ifdef _WIN32
		cmd.append("@for /d %X in (" + BUILD_DIR_PREFIX + "*) do @del /f /s /q \"%X\\CMakeCache.txt\" > NUL");
#	else
		cmd.append("find . -mindepth 2 -maxdepth 2 -name CMakeCache.txt | xargs /bin/rm -f");
#	endif
	}
	else
	{
		message(cmd, "Cleaning the configuration of " + config + " build.");

		const std::string build_dir = get_build_dir(config);

#	ifdef _WIN32
		cmd.append("if exist \"" + build_dir + "\\CMakeCache.txt\"" + " @del /f /s /q \"" + build_dir + "\\CMakeCache.txt\" > NUL");
#	else
		cmd.append("/bin/rm -f \"" + build_dir + "/CMakeCache.txt\"");
#	endif
	}
	
	return 0;
}

int clean_make(system_commands& cmd, const std::string& config, const std::string& target)
{
	if (config.empty())
	{
		if (target.empty())
		{
			message(cmd, "Cleaning the built binaries in all builds.");
		}
		else
		{
			message(cmd, "Cleaning the built binaries of target(s) " + target + " in all builds.");
		}

#	ifdef _WIN32
		cmd.append("@for /d %X in (" + BUILD_DIR_PREFIX + "*) do @ninja -C \"%X\" -t clean " + target);
#	else
		cmd.append("for build_dir in `ls | grep \"" + BUILD_DIR_PREFIX + "\"`; do ninja -C \"$build_dir\" -t clean " + target + "; done");
#	endif
	}
	else
	{
		if (target.empty())
		{
			message(cmd, "Cleaning the built binaries in " + config + " build.");
		}
		else
		{
			message(cmd, "Cleaning the built binaries of target(s) " + target + " in " + config + " build.");
		}

		const std::string build_dir = get_build_dir(config);

	#if 1
		cmd.append("ninja -C \"" + build_dir + "\" -t clean " + target);
	#else
		cmd.append("cmake --build \"" + build_dir + "\" --target clean"); // ONLY IF TARGET IS EMPTY
	#endif
	}
	
	return 0;
}

int clean_config_and_make(system_commands& cmd, const std::string& config)
{
	if (config.empty()) // Clean ALL build directories
	{
		message(cmd, "Cleaning all builds.");

#	ifdef _WIN32
		// First delete all files in the build directory and its subdirectories recursively to avoid the common problem
		// that removing the build directory fails with error message "The directory is not empty".
		cmd.append("@for /d %X in (" + BUILD_DIR_PREFIX + "*) do @del /f /s /q \"%X\" > NUL && @rd /s /q \"%X\"");
#	else
		cmd.append("ls | grep \"" + BUILD_DIR_PREFIX + "\" | xargs /bin/rm -rf");
#	endif
	}
	else // Clean config build directory
	{
		message(cmd, "Cleaning " + config + " build.");

		const std::string build_dir = get_build_dir(config);

#	ifdef _WIN32
		cmd.append("if exist \"" + build_dir + "\" @del /f /s /q \"" + build_dir + "\" > NUL && @rd /s /q \"" + build_dir + "\"");
#	else
		cmd.append("/bin/rm -rf \"" + build_dir + "\"");
#	endif
	}

	return 0;
}

int clean(system_commands& cmd, const std::string& config, const std::string& target, bool make_flag)
{
	if (make_flag || !target.empty()) // Clean only the built binaries created by the make command
	{
		return clean_make(cmd, config, target);
	}
	else // Clean the whole build directory
	{
		return clean_config_and_make(cmd, config);
	}

	return 0;
}

int commands(system_commands& cmd, std::string config, const std::string& target)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	if (target.empty())
	{
		message(cmd, "Listing commands of " + config + " build.");
	}
	else
	{
		message(cmd, "Listing commands of " + config + " build target " + target + ".");
	}

	const std::string build_dir = get_build_dir(config);

	cmd.append("ninja -C \"" +  build_dir + "\" -t commands " + target);

	return 0;
}

int headers(system_commands& cmd, std::string config)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	message(cmd, "Listing dependencies of " + config + " build.");

	const std::string build_dir = get_build_dir(config);

	cmd.append("ninja -C \"" +  build_dir + "\" -t headers");

	return 0;
}

int getenv(system_commands& cmd, const std::string& var)
{
#	ifdef _WIN32
	cmd.append("echo %" + var + "%");
#	else
	cmd.append("echo ${" + var + "}");
#	endif
	
	return 0;
}

int setenv(system_commands& cmd, const std::string& var, const std::string& value)
{
#	ifdef _WIN32
	cmd.append("setx " + var + " " + value);
#	else
	cmd.append("echo 'export " + var + "=\"" + value + "\"' >> ~/.bash_profile");
#	endif
	
	return 0;
}

int help(system_commands& cmd)
{
	message(cmd, "God helps those who help themselves.");
	return 0;
}

int gethost(system_commands& cmd)
{
	cmd.append("clang -dumpmachine");
	return 0;
}

int install(system_commands& cmd, std::string config)
{
	if (config.empty()) config = DEFAULT_CONFIG;
	
	const std::string build_dir = get_build_dir(config);
	
#if _WIN32
	add_set_environment_command(cmd, "x64");
#endif

	cmd.append("cmake --build " + build_dir + " --target install");
	
	return 0;
}

template <typename Func>
void split_string(const std::string& str, char delimiter, Func&& func)
{
	size_t from = 0;

	for (size_t i = 0; i < str.size(); ++i)
	{
		if (str[i] == delimiter)
		{
			func(str, from, i);
			from = i + 1;
		}
	}

	if (from <= str.size())
	{
		func(str, from, str.size());
	}
}

void split_string_to_vector(const std::string& str, char delimiter, std::vector<std::string>& output)
{
	split_string(str, delimiter, [&](const std::string &s, size_t from, size_t to)
	{
		const std::string sub =  s.substr(from, to - from);
		if (!sub.empty()) output.push_back(sub);
	});
}

int deploy(system_commands& cmd, std::string config)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	return 0;
}

int query_deps(const std::string& executable, std::vector<runtime_dependency>& deps)
{
	if (executable.empty()) return 0;

	system_commands cmd;

#if _WIN32

	std::regex regex{ "\\s*(.*\\.[dD][lL][lL])[\\r\\n]*" };
	add_set_environment_command(cmd, "x64");
	cmd.append("dumpbin /nologo /dependents " + executable);

#elif __APPLE__

	std::regex regex{ "\\t([^\\t]+) \\(compatibility version ([0-9]+.[0-9]+.[0-9]+), current version ([0-9]+.[0-9]+.[0-9]+)\\)" };
	// name (@executable_path.*) \(offset \d+\)
	// name (@rpath.*) \(offset \d+\)
	// path (.*) \(offset \d+\)
	cmd.append("otool -L " + executable);

#else

	std::regex regex{ "\\s*[^\\t ]+ => ([^\\s]+).*" };
	cmd.append("ldd " + executable);

#endif

	std::string cmdout = exec(cmd);

	auto matches_begin = std::sregex_iterator(cmdout.begin(), cmdout.end(), regex);
	auto matches_end = std::sregex_iterator();

	for (auto it = matches_begin; it != matches_end; ++it)
	{
		deps.emplace_back((*it)[1]);
	}

	return 0;
}

int getdeps(system_commands& cmd, const std::string& executable)
{
	if (executable.empty()) return 0;

	std::vector<runtime_dependency> deps;
	query_deps(executable, deps);

	for (const runtime_dependency& dep : deps)
	{
		std::cout << dep.unresolved << std::endl;
	}

	return 0;
}

int query_rpaths(const std::string& executable, std::vector<std::string>& rpaths)
{
	if (executable.empty()) return 0;

#ifndef _WIN32

	system_commands cmd;

#if __APPLE__

	std::regex regex{ "path (.*) \\(offset \\d+\\)" };
	cmd.append("otool -l " + executable + " | grep RPATH -A2");

#else

	std::regex regex{ "\\[(.*)\\]" };
	cmd.append("readelf -d " + executable + " | grep -P \"R.*PATH\"");

#endif
	
	std::string cmdout = exec(cmd);

	auto matches_begin = std::sregex_iterator(cmdout.begin(), cmdout.end(), regex);
	auto matches_end = std::sregex_iterator();

	for (auto it = matches_begin; it != matches_end; ++it)
	{
		rpaths.push_back((*it)[1]);
	}

#endif

	return 0;
}

int getrpaths(system_commands& cmd, const std::string& executable)
{
	if (executable.empty()) return 0;

	std::vector<std::string> rpaths;
	query_rpaths(executable, rpaths);

	for (const std::string& rpath : rpaths)
	{
		std::cout << rpath << std::endl;
	}

	return 0;
}

int resolve_deps(std::vector<runtime_dependency>& deps, const std::vector<std::string>& rpaths, const std::vector<std::string>& syspaths)
{
	int error = 0;

	for (runtime_dependency& dep : deps)
	{
		if (!dep.resolve(rpaths, syspaths)) ++error;
	}

	return error;
}

int copy_resolved_deps(const std::vector<runtime_dependency>& resolved_deps, const std::string& target_path)
{
	for (const runtime_dependency& resolved_dep : resolved_deps)
	{

	}

	return 0;
}

int fixup_bundle(const std::string& executable, const std::vector<runtime_dependency>& deps, const std::vector<std::string>& rpaths)
{
	system_commands cmd;

#	if _WIN32

	// Do nothing

#	elif __APPLE__

	// Change install names

	for (const runtime_dependency& dep : deps)
	{
		if (!dep.is_resolved()) continue; // error

		cmd.append("install_name_tool -change " + dep.unresolved + " " + dep.bundled + " " + executable);
		//cmd.append("install_name_tool -rpath " + dep.unresolved + " " + dep.bundled + " " + executable);
	}

	// Delete all rpaths

	for (const std::string& rpath : rpaths)
	{
		cmd.append("install_name_tool -delete-rpath " + rpath + " " + executable);
	}

	// Add new, relative rpath

	cmd.append("install_name_tool -add-rpath @executable_path/../Frameworks" + executable);

#	else

	// Set new, relative rpath

	copy_resolved_deps(deps, executable + "/../lib");
	cmd.append("patchelf --set-rpath $ORIGIN/../lib " + executable);

#	endif

	return 0;
}

int validate_bundle()
{
	return 0;
}

int bundle(system_commands& cmd, const std::string& executable, std::string rpaths_delimited)
{
	std::vector<runtime_dependency> deps;
	std::vector<std::string> rpaths;
	std::vector<std::string> syspaths;

	split_string_to_vector(rpaths_delimited, ';', rpaths);
	query_syspaths(syspaths);

	std::string PATH = get_env_var("PATH");
	split_string_to_vector(PATH, ';', syspaths);

	// List rpaths

	std::cout << "Search paths:" << std::endl << std::endl;

	for (const std::string& rpath : rpaths)
	{
		std::cout << rpath << std::endl;
	}

	std::cout << std::endl;

	// List syspaths

	std::cout << "System paths:" << std::endl << std::endl;

	for (const std::string& syspath : syspaths)
	{
		std::cout << syspath << std::endl;
	}

	std::cout << std::endl;

	// Get dependecies

	query_deps(executable, deps);

	std::cout << "Runtime dependencies:" << std::endl << std::endl;

	for (const runtime_dependency& dep : deps)
	{
		std::cout << dep.unresolved << std::endl;
	}

	std::cout << std::endl;

	// Resolve

	resolve_deps(deps, rpaths, syspaths);

	std::cout << "Resolved runtime dependencies:" << std::endl << std::endl;

	for (const runtime_dependency& dep : deps)
	{
		if (dep.is_resolved() && !dep.is_system())
		{
			std::cout << dep.resolved << std::endl;
		}
	}

	std::cout << std::endl;

	std::cout << "Resolved system runtime dependencies:" << std::endl << std::endl;

	for (const runtime_dependency& dep : deps)
	{
		if (dep.is_resolved() && dep.is_system())
		{
			std::cout << dep.resolved << std::endl;
		}
	}

	std::cout << std::endl;

	std::cout << "Unresolved runtime dependencies:" << std::endl << std::endl;

	for (const runtime_dependency& dep : deps)
	{
		if (!dep.is_resolved()) std::cout << dep.unresolved << std::endl;
	}

	std::cout << std::endl;

	// Bundle

	std::cout << "Bundled runtime dependencies:" << std::endl << std::endl;

	const std::string bundle_lib_dir = get_bundle_lib_dir(executable);

	make_directory(bundle_lib_dir);

	for (runtime_dependency& dep : deps)
	{
		if (!dep.is_system())
		{
			dep.bundle(bundle_lib_dir);
			if (dep.is_bundled()) std::cout << dep.bundled << std::endl;
		}
	}

	std::cout << std::endl;

	// Fixup

	fixup_bundle(executable, deps, rpaths);

	// Verify

	return 0;
}

int fix_binary(system_commands& cmd, const std::string& executable, std::string old_path, std::string new_path)
{


	return 0;
}

int codesign(system_commands& cmd, const std::string& identity, const std::string& bundlepath)
{
#if __APPLE__
	cmd.append("codesign -s " + identity + " " + bundlepath);
	cmd.append("codesign -v " + bundlepath);
#else
	cmd.append("echo No codesign required on this platform.");
#endif

	return 0;
}

int reconfig(system_commands& cmd, std::string config, const std::string& toolchain)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	if (clean_config(cmd, config) != 0) return 1;
	return configure(cmd, config, toolchain);
}

int remake(system_commands& cmd, std::string config, const std::string& target, const std::string& max_threads, bool refresh_flag)
{
	if (config.empty()) config = DEFAULT_CONFIG;

#if 1

	if (clean_make(cmd, config, target) != 0) return 1;
	return make(cmd, config, "", target, max_threads, false, refresh_flag);

#else

	const std::string build_dir = get_build_dir(config);

	cmd.append("cmake --build \"" + build_dir + "\" --clean-first");
	return 0;

#endif
}

int version(system_commands& cmd)
{
	message(cmd, VERSION);
	return 0;
}

int check_args_count(const argh::parser& args, size_t max)
{
	if ((args.size() + args.flags().size() + args.params().size()) > max)
	{
		std::cout << "WARNING Too many arguments for this command." << std::endl;
		return 1;
	}

	return 0;
}

int main(int argc, char** argv)
{
	// Parsing arguments

	std::initializer_list<char const* const> exclusive_param{ "-x", "-X", "--exclusive" };
	std::initializer_list<char const* const> maxthreads_param{ "-j", "-J", "--maxthreads" };
	std::initializer_list<char const* const> toolchain_param{ "-t", "-T", "--toolchain" };

	argh::parser args;
	args.add_params(exclusive_param);
	args.add_params(maxthreads_param);
	args.add_params(toolchain_param);
	args.parse(argc, argv);

	// Perform command

	system_commands cmd;
	int retval;

	std::string command = args(1).str();

	if (command == "headers")
	{
		if (check_args_count(args, 3)) return 1;
		retval = headers(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	if (command == "help")
	{
		if (check_args_count(args, 3)) return 1;
		retval = help(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "version")
	{
		if (check_args_count(args, 3)) return 1;
		retval = version(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "bundle")
	{
		if (check_args_count(args, 4)) return 1;
		retval = bundle(cmd, args(2).str(), args(3).str());
		if (retval != 0) return retval;
	}
	else if (command == "clean")
	{
		if (check_args_count(args, 5)) return 1;
		retval = clean(cmd, args(2).str(), args(exclusive_param).str(), args[exclusive_param]);
		if (retval != 0) return retval;
	}
	else if (command == "codesign")
	{
		if (check_args_count(args, 4)) return 1;
		retval = codesign(cmd, args(2).str(), args(3).str());
		if (retval != 0) return retval;
	}
	else if (command == "commands")
	{
		if (check_args_count(args, 4)) return 1;
		retval = commands(cmd, args(2).str(), args(exclusive_param).str());
		if (retval != 0) return retval;
	}
	else if (command == "conf" || command == "config")
	{
		if (check_args_count(args, 4)) return 1;
		retval = configure(cmd, args(2).str(), args(toolchain_param).str());
		if (retval != 0) return retval;
	}
	else if (command == "deploy")
	{
		if (check_args_count(args, 3)) return 1;
		retval = deploy(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "install")
	{
		if (check_args_count(args, 3)) return 1;
		retval = install(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "make")
	{
		if (check_args_count(args, 8)) return 1;
		retval = make(cmd, args(2).str(), args(toolchain_param).str(), args(exclusive_param).str(), args(maxthreads_param).str(), args[{ "-c", "-C" }], args[{ "-r", "-R" }]);
		if (retval != 0) return retval;
	}
	else if (command == "reconf" || command == "reconfig")
	{
		if (check_args_count(args, 4)) return 1;
		retval = reconfig(cmd, args(2).str(), args(toolchain_param).str());
		if (retval != 0) return retval;
	}
	else if (command == "refresh")
	{
		if (check_args_count(args, 3)) return 1;
		retval = refresh(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "remake")
	{
		if (check_args_count(args, 6)) return 1;
		retval = remake(cmd, args(2).str(), args(exclusive_param).str(), args(maxthreads_param).str(), args[{ "-r", "-R" }]);
		if (retval != 0) return retval;
	}
	else if (command == "getdeps")
	{
		if (check_args_count(args, 3)) return 1;
		retval = getdeps(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "getenv")
	{
		if (check_args_count(args, 3)) return 1;
		retval = getenv(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "gethost")
	{
		if (check_args_count(args, 3)) return 1;
		retval = gethost(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "getrpaths")
	{
		if (check_args_count(args, 3)) return 1;
		retval = getrpaths(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "setenv")
	{
		if (check_args_count(args, 4)) return 1;
		retval = setenv(cmd, args(2).str(), args(3).str());
		if (retval != 0) return retval;
	}
	else
	{
		if (command.empty())
		{
			std::cout << "No command specified." << std::endl;
			return 0;
		}
		else
		{
			std::cerr << "ERROR Invalid command: " << command << std::endl;
			return 1;
		}
	}

	std::system(cmd);

	return 0;
}
