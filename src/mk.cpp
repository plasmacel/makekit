#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>

static const std::string VERSION = "0.1";

static const std::string BUILD_DIR_PREFIX = "build.";
static const std::string DEFAULT_BUILD_TYPE = "release";

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

std::string get_dir(const std::string& build_type)
{
	return BUILD_DIR_PREFIX + build_type;
}

std::string get_env_var(const std::string& variable)
{
	std::string value;

#ifdef _WIN32
	char* buf = nullptr;
	size_t n = 0;

	if ((_dupenv_s(&buf, &n, variable.c_str()) == 0) && (buf != nullptr))
	{
		value.assign(buf, n);
		std::free(buf);
	}
#else
	value = std::getenv(variable.c_str());
#endif

	return value;
}

void where_path(const std::string& filename, system_commands& cmd)
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
	std::system(std::string{"where /q " + filename}.c_str());
	return get_env_var("ERRORLEVEL") == "0";
#else
	std::system(std::string{"which " + filename}.c_str());
	return get_env_var("?") == "0";
#endif
}

#ifdef _WIN32
void add_set_environment_command(const std::string& host_arch, const std::string& target_arch, system_commands& cmd)
{
	std::string current_host_arch = get_env_var("VSCMD_ARG_HOST_ARCH");
	std::string current_target_arch = get_env_var("VSCMD_ARG_TGT_ARCH");

	if ((current_host_arch != host_arch) || (current_target_arch != target_arch))
	{
		cmd.append("vswhere -nologo -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > vsdevcmd_dir.txt");
		cmd.append("set /p VSDEVCMD_DIR=< vsdevcmd_dir.txt");
		cmd.append("del vsdevcmd_dir.txt");
		cmd.append("call \"%VSDEVCMD_DIR%\\Common7\\Tools\\VsDevCmd.bat\" -arch=" +  target_arch + " -host_arch=" + host_arch);
	}
}

void add_set_environment_command(const std::string& arch, system_commands& cmd)
{
	add_set_environment_command(arch, arch, cmd);
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

int config(const std::string& build_type, system_commands& cmd)
{
	std::string cmake_build_type;

	if (build_type == "debug")
	{
		cmake_build_type = "Debug";
	}
	else if (build_type == "release-debuginfo")
	{
		cmake_build_type = "RelWithDebInfo";
	}
	else if (build_type == "release")
	{
		cmake_build_type = "Release";
	}
	else if (build_type == "release-minsize")
	{
		cmake_build_type = "MinSizeRel";
	}
	else
	{
		// Using a custom build type.
	}

	// Compose terminal commands
	
	const std::string build_dir = get_dir(build_type);

	// Append set environment command (required on Windows only)

#ifdef _WIN32
	add_set_environment_command("x64", cmd);
	//cmd.append("set MK_CURRENT_DIR=%cd%");
	//cmd.append("pushd \"%MK_CURRENT_DIR%\"");
	//cmd.append("echo good so far");
#endif

	// Append run CMake command

	std::string cmake_command = "cmake .";
	cmake_command += " -GNinja";
	cmake_command += " -B" + build_dir;
	cmake_command += " -DCMAKE_BUILD_TYPE=" + cmake_build_type;
#ifdef _WIN32
	cmake_command += " -DCMAKE_TOOLCHAIN_FILE=\"%MK_DIR%/cmake/toolchains/llvm.native.toolchain.cmake\"";
#else
	cmake_command += " -DCMAKE_TOOLCHAIN_FILE=\"$MK_DIR/cmake/toolchains/llvm.native.toolchain.cmake\"";
#endif

#ifdef _WIN32
	//cmd.append("popd");
#endif

	cmd.append(cmake_command);

	return 0;
}

int make(const std::string& build_type, system_commands& cmd)
{
	const std::string build_dir = get_dir(build_type);
	
	// Config or refresh
	
	if (config(build_type, cmd) != 0) return 1;
	
	// Add Ninja build command

	std::string ninja_status = read_file("mk_status.txt");
	
	if (!ninja_status.empty())
	{
	#ifdef _WIN32
		cmd.append("set \"NINJA_STATUS=" + ninja_status + " \"");
	#else
		cmd.append("export \"NINJA_STATUS=" + ninja_status + " \"");
	#endif
	}

	cmd.append("ninja -C " + build_dir);
#ifdef _WIN32
	cmd.append("if %ERRORLEVEL% == 0 ( echo Build succeeded. ) else ( echo Build failed. )");
#else
	cmd.append("if [ $? -eq 0 ]; then echo Build succeeded.; else echo Build failed.; fi");
#endif
	//cmd.append("cmake --build " + build_dir + " --target " + build_target + " --config " + build_type);
	return 0;
}

int clean_all(const std::string& build_type, system_commands& cmd)
{
	const std::string build_dir = get_dir(build_type);
	
#ifdef _WIN32
	cmd.append("@if exist " + build_dir + " @rd /s /q " + build_dir);
#else
	cmd.append("rm -r -f " + build_dir);
#endif
	return 0;
}

int clean_config(const std::string& build_type, system_commands& cmd)
{
	const std::string build_dir = get_dir(build_type);

#ifdef _WIN32
	cmd.append("@if exist " + build_dir + "\\CMakeCache.txt" + " @del /f /q " + build_dir + "\\CMakeCache.txt");
#else
	cmd.append("rm -f " + build_dir + "/CMakeCache.txt");
#endif
	return 0;
}

int clean_make(const std::string& build_type, system_commands& cmd)
{
	const std::string build_dir = get_dir(build_type);

	cmd.append("ninja -C " + build_dir + " -t clean");
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

int refresh(const std::string& build_type, system_commands& cmd)
{
	return config(build_type, cmd);
}

int reconfig(const std::string& build_type, system_commands& cmd)
{
	if (clean_config(build_type, cmd) != 0) return 1;
	return config(build_type, cmd);
}

int remake(const std::string& build_type, system_commands& cmd)
{
	if (clean_make(build_type, cmd) != 0) return 1;
	return make(build_type, cmd);
}

int version(system_commands& cmd)
{
	std::cout << VERSION << std::endl;
	return 0;
}

int main(int argc, char** argv)
{
	std::string command;
	std::string build_type;

	system_commands cmd;
	int retval;

	if (argc > 1) command = argv[1];
	if (argc > 2) build_type = argv[2];

	if (!command.empty() && build_type.empty()) build_type = DEFAULT_BUILD_TYPE;

	if (command == "help")
	{
		if (argc > 2) return 1;
		retval = help(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "host")
	{
		if (argc > 2) return 1;
		retval = hostinfo(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "version")
	{
		if (argc > 2) return 1;
		retval = version(cmd);
		if (retval != 0) return retval;
	}
	else if (command == "clean")
	{
		retval = clean_all(build_type, cmd);
		if (retval != 0) return retval;
		std::cout << "Cleaning " << build_type << " build..." << std::endl;
	}
	else if (command == "config")
	{
		retval = config(build_type, cmd);
		if (retval != 0) return retval;
		std::cout << "Configuring " << build_type << " build..." << std::endl;
	}
	else if (command == "make")
	{
		retval = make(build_type, cmd);
		if (retval != 0) return retval;
		std::cout << "Making " << build_type << " build..." << std::endl;
	}
	else if (command == "reconfig")
	{
		retval = reconfig(build_type, cmd);
		if (retval != 0) return retval;
		std::cout << "Reconfiguring " << build_type << " build..." << std::endl;
	}
	else if (command == "refresh")
	{
		retval = refresh(build_type, cmd);
		if (retval != 0) return retval;
		std::cout << "Refresh " << build_type << " build..." << std::endl;
	}
	else if (command == "remake")
	{
		retval = remake(build_type, cmd);
		if (retval != 0) return retval;
		std::cout << "Remaking " << build_type << " build..." << std::endl;
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
