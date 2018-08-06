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
#include <fstream>
#include <iostream>
#include <string>
#include "argh.h"

static const std::string VERSION = "0.2";
static const std::string BUILD_DIR_PREFIX = "build.";
static const std::string DEFAULT_CONFIG = "Release";
static const std::string DEFAULT_TOOLCHAIN = "llvm.native";

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
};

std::string get_dir(const std::string& config)
{
	return BUILD_DIR_PREFIX + config;
}

std::string get_env_var(const std::string& variable)
{
	std::string value;

#ifdef _WIN32
	char* buf = nullptr;
	size_t n = 0;

	if ((_dupenv_s(&buf, &n, variable.c_str()) == 0) && (buf != nullptr))
	{
		value.assign(buf, n-1);
		std::free(buf);
	}
#else
	value = std::getenv(variable.c_str());
#endif

	return value;
}

void message(system_commands& cmd, const std::string& msg)
{
	cmd.append("echo " + msg);

#ifdef _WIN32
	cmd.append("echo.");
#else
	cmd.append("echo -n \"\n\"");
#endif
}

void where_path(system_commands& cmd, const std::string& filename)
{
#ifdef _WIN32
	cmd.append("where " + filename);
#else
	cmd.append("which " + filename);
#endif
}

bool has_path(const std::string& filename)
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

void add_set_environment_command(system_commands& cmd, const std::string& arch)
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

	// Compose terminal commands
	
	const std::string build_dir = get_dir(config);

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

	std::cout << "Configuring " << config << " build..." << std::endl;

	return 0;
}

int refresh(system_commands& cmd, std::string config)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	// Compose terminal commands

	const std::string build_dir = get_dir(config);

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

	std::cout << "Refreshing " << config << " build..." << std::endl;

	return 0;
}

int make(system_commands& cmd, std::string config, const std::string& toolchain, std::string target, bool configure_flag, bool refresh_flag)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	const std::string build_dir = get_dir(config);
	
	// Configure or refresh
	
	if (configure_flag)
	{
		if (configure(cmd, config, toolchain) != 0) return 1;
	}
	else
	{
		if (!toolchain.empty())
		{
			cmd.append("echo Toolchain is ignored without the config (-C) flag.");
		}

		if (refresh_flag)
		{
			if (refresh(cmd, config)) return 1;
		}

		add_set_environment_command(cmd, "x64");
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

	if (target.empty()) // Build all targets
	{
		cmd.append("ninja -C \"" + build_dir + "\"");
	}
	else
	{
		if (target.back() == '^') // Compiling a single source
		{
			cmd.append("ninja -C \"" + build_dir + "\" \"../" + target + "\"");
		}
		else // Building a single target
		{
		#if 1
			cmd.append("ninja -C \"" + build_dir + "\" " + target);
		#else
			cmd.append("cmake --build \"" + build_dir + "\" --target " + target);
		#endif
		}
	}

#	ifdef _WIN32
	cmd.append("if %ERRORLEVEL% == 0 ( echo Build succeeded. ) else ( echo Build failed. )");
#	else
	cmd.append("if [ $? -eq 0 ]; then echo Build succeeded.; else echo Build failed.; fi");
#	endif

	if (target.back() == '^')
	{
		target.pop_back();
		std::cout << "Compiling " << target << " using " << config << " build..." << std::endl;
	}
	else
	{
		if (target.empty())
		{
			std::cout << "Building all using " << config << " build..." << std::endl;
		}
		else
		{
			std::cout << "Building " << target << " using " << config << " build..." << std::endl;
		}
	}

	return 0;
}

int clean_config(system_commands& cmd, const std::string& config)
{
	if (config.empty()) // Clean CMakeCache.txt of ALL build configurations
	{
#	ifdef _WIN32
		cmd.append("@for /d %X in (" + BUILD_DIR_PREFIX + "*) do @del /f /s /q \"%X\\CMakeCache.txt\"");
#	else
		cmd.append("find . -mindepth 2 -maxdepth 2 -name CMakeCache.txt | xargs /bin/rm -f");
#	endif

		std::cout << "Cleaning the configuration of all builds..." << std::endl;
	}
	else
	{
		const std::string build_dir = get_dir(config);

#	ifdef _WIN32
		cmd.append("if exist \"" + build_dir + "\\CMakeCache.txt\"" + " @del /f /s /q \"" + build_dir + "\\CMakeCache.txt\"");
#	else
		cmd.append("/bin/rm -f \"" + build_dir + "/CMakeCache.txt\"");
#	endif

		std::cout << "Cleaning the configuration of " << config << " build..." << std::endl;
	}
	
	return 0;
}

int clean_make(system_commands& cmd, const std::string& config, const std::string& target)
{
	if (config.empty())
	{
#	ifdef _WIN32
		cmd.append("@for /d %X in (" + BUILD_DIR_PREFIX + "*) do @ninja -C \"%X\" -t clean " + target);
#	else
		cmd.append("for build_dir in `ls | grep \"" + BUILD_DIR_PREFIX + "\"`; do ninja -C \"$build_dir\" -t clean " + target + "; done");
#	endif

		if (target.empty())
		{
			std::cout << "Cleaning the built binaries in all builds..." << std::endl;
		}
		else
		{
			std::cout << "Cleaning the built binaries of target(s) " <<  target << " in all builds..." << std::endl;
		}
	}
	else
	{
		const std::string build_dir = get_dir(config);

	#if 1
		cmd.append("ninja -C \"" + build_dir + "\" -t clean " + target);
	#else
		cmd.append("cmake --build \"" + build_dir + "\" --target clean"); // ONLY IF TARGET IS EMPTY
	#endif

		if (target.empty())
		{
			std::cout << "Cleaning the built binaries in " << config << " build..." << std::endl;
		}
		else
		{
			std::cout << "Cleaning the built binaries of target(s) " << target << " in " << config << " build..." << std::endl;
		}
	}
	
	return 0;
}

int clean_config_and_make(system_commands& cmd, const std::string& config)
{
	if (config.empty()) // Clean ALL build directories
	{
#	ifdef _WIN32
		// First delete all files in the build directory and its subdirectories recursively to avoid the common problem
		// that removing the build directory fails with error message "The directory is not empty".
		cmd.append("@for /d %X in (" + BUILD_DIR_PREFIX + "*) do @del /f /s /q \"%X\" && @rd /s /q \"%X\"");
#	else
		cmd.append("ls | grep \"" + BUILD_DIR_PREFIX + "\" | xargs /bin/rm -rf");
#	endif

		std::cout << "Cleaning all builds..." << std::endl;
	}
	else // Clean config build directory
	{
		const std::string build_dir = get_dir(config);

#	ifdef _WIN32
		cmd.append("if exist \"" + build_dir + "\" @del /f /s /q \"" + build_dir + "\" && @rd /s /q \"" + build_dir + "\"");
#	else
		cmd.append("/bin/rm -rf \"" + build_dir + "\"");
#	endif

		std::cout << "Cleaning " << config << " build..." << std::endl;
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

	const std::string build_dir = get_dir(config);

	cmd.append("ninja -C \"" +  build_dir + "\" -t commands " + target);

	if (target.empty())
	{
		std::cout << "Listing commands of " << config << " build..." << std::endl;
	}
	else
	{
		std::cout << "Listing commands of " << config << " build target " <<  target << "..." << std::endl;
	}

	return 0;
}

int deps(system_commands& cmd, std::string config)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	const std::string build_dir = get_dir(config);

	cmd.append("ninja -C \"" +  build_dir + "\" -t deps");

	std::cout << "Listing dependencies of " << config << " build..." << std::endl;

	return 0;
}

int help(system_commands& cmd)
{
	cmd.append("echo God helps those who help themselves.");
	return 0;
}

int hostinfo(system_commands& cmd)
{
	cmd.append("clang -dumpmachine");
	return 0;
}

int reconfig(system_commands& cmd, std::string config, const std::string& toolchain)
{
	if (config.empty()) config = DEFAULT_CONFIG;

	if (clean_config(cmd, config) != 0) return 1;
	return configure(cmd, config, toolchain);
}

int remake(system_commands& cmd, std::string config, const std::string& target, bool refresh_flag)
{
	if (config.empty()) config = DEFAULT_CONFIG;

#if 1

	if (clean_make(cmd, config, target) != 0) return 1;
	return make(cmd, config, "", target, false, refresh_flag);

#else

	const std::string build_dir = get_dir(config);

	cmd.append("cmake --build \"" + build_dir + "\" --clean-first");
	return 0;

#endif
}

int version(system_commands& cmd)
{
	std::cout << VERSION << std::endl;
	return 0;
}

int main(int argc, char** argv)
{
	// Parsing arguments

	std::initializer_list<char const* const> exclusive_param{ "-x", "-X", "--exclusive" };
	std::initializer_list<char const* const> toolchain_param{ "-t", "-T", "--toolchain" };

	argh::parser args;
	args.add_params(exclusive_param);
	args.add_params(toolchain_param);
	args.parse(argc, argv);

	// Perform command

	system_commands cmd;
	int retval;

	std::string command = args(1).str();

	if (command == "deps")
	{
		if (args.size() > 2) return 1;
		retval = deps(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	if (command == "help")
	{
		if (args.size() > 2) return 1;
		retval = help(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "host")
	{
		if (args.size() > 2) return 1;
		retval = hostinfo(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "version")
	{
		if (args.size() > 2) return 1;
		retval = version(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "clean")
	{
		if (args.size() > 4) return 1;
		retval = clean(cmd, args(2).str(), args(exclusive_param).str(), args[exclusive_param]);
		if (retval != 0) return retval;
	}
	else if (command == "commands")
	{
		if (args.size() > 3) return 1;
		retval = commands(cmd, args(2).str(), args(exclusive_param).str());
		if (retval != 0) return retval;
	}
	else if (command == "config")
	{
		if (args.size() > 3) return 1;
		retval = configure(cmd, args(2).str(), args(toolchain_param).str());
		if (retval != 0) return retval;
	}
	else if (command == "make")
	{
		if (args.size() > 6) return 1;
		retval = make(cmd, args(2).str(), args(toolchain_param).str(), args(exclusive_param).str(), args[{ "-c", "-C" }], args[{ "-r", "-R" }]);
		if (retval != 0) return retval;
	}
	else if (command == "reconfig")
	{
		if (args.size() > 3) return 1;
		retval = reconfig(cmd, args(2).str(), args(toolchain_param).str());
		if (retval != 0) return retval;
	}
	else if (command == "refresh")
	{
		if (args.size() > 2) return 1;
		retval = refresh(cmd, args(2).str());
		if (retval != 0) return retval;
	}
	else if (command == "remake")
	{
		if (args.size() > 4) return 1;
		retval = remake(cmd, args(2).str(), args(exclusive_param).str(), args[{ "-r", "-R" }]);
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
