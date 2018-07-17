#include <cstdlib>
#include <iostream>
#include <string>

static const std::string BUILD_DIR_PREFIX = "build.";
static const std::string DEFAULT_BUILD_TYPE = "release";

#ifdef _WIN32
static const std::string MAKEKIT_ASM_COMPILER = "ml64.exe";
static const std::string MAKEKIT_C_COMPILER = "clang-cl.exe";
static const std::string MAKEKIT_CXX_COMPILER = "clang-cl.exe";
static const std::string MAKEKIT_CUDA_COMPILER = "nvcc.exe";
static const std::string MAKEKIT_RC_COMPILER = "rc.exe";
static const std::string MAKEKIT_LINKER = "lld-link.exe";
#else
static const std::string MAKEKIT_ASM_COMPILER = "llvm-as";
static const std::string MAKEKIT_C_COMPILER = "clang";
static const std::string MAKEKIT_CXX_COMPILER = "clang++";
static const std::string MAKEKIT_CUDA_COMPILER = "nvcc";
static const std::string MAKEKIT_RC_COMPILER = "";
static const std::string MAKEKIT_LINKER = "lld";
#endif

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
			sep = " & ";
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
	value = std::get_env_var(variable.c_str());
	#endif

	return value;
}

#ifdef _WIN32
void add_set_environment_command(const std::string& host_arch, const std::string& target_arch, system_commands& cmd)
{
	std::string current_host_arch = get_env_var("VSCMD_ARG_HOST_ARCH");
	std::string current_target_arch = get_env_var("VSCMD_ARG_TGT_ARCH");
	
	if ((current_host_arch != host_arch) || (current_target_arch != target_arch))
	{
		cmd.append("call vcvars64.bat");
	}
}

void add_set_environment_command(const std::string& arch, system_commands& cmd)
{
	add_set_environment_command(arch, arch, cmd);
}
#endif

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
		cmake_build_type = "RelMinSize";
	}
	else
	{
		std::cout << "ERROR Invalid build type: " << build_type << std::endl;
		return 1;
	}

	// Compose terminal commands

	// Append set environment command (required on Windows only)

	#ifdef _WIN32
	add_set_environment_command("x64", cmd);
	#endif
	
	// Append run CMake command

	std::string cmake_command = "cmake .";
	cmake_command += " -GNinja";
	cmake_command += " -B" + BUILD_DIR_PREFIX + build_type;
	//cmake_command += " -DCMAKE_ASM_COMPILER:PATH=\"" + MAKEKIT_ASM_COMPILER + "\"";
	cmake_command += " -DCMAKE_C_COMPILER:PATH=\"" + MAKEKIT_C_COMPILER + "\"";
	cmake_command += " -DCMAKE_CXX_COMPILER:PATH=\"" + MAKEKIT_CXX_COMPILER + "\"";
	//cmake_command += " -DCMAKE_CUDA_COMPILER:PATH=\"" + MAKEKIT_CUDA_COMPILER + "\"";
	cmake_command += " -DCMAKE_RC_COMPILER:PATH=\"" + MAKEKIT_RC_COMPILER + "\"";
	cmake_command += " -DCMAKE_LINKER:PATH=\"" + MAKEKIT_LINKER + "\"";
	cmake_command += " -DCMAKE_BUILD_TYPE=" + cmake_build_type;

	cmd.append(cmake_command);
	
	return 0;
}

int make(const std::string& build_type, system_commands& cmd)
{
	// Config or refresh
	
	if (config(build_type, cmd) != 0) return 1;

	// Add Ninja build command

	cmd.append("ninja -C " + BUILD_DIR_PREFIX + build_type);

	return 0;
}

int clean_all(const std::string& build_type, system_commands& cmd)
{
	#ifdef _WIN32
	cmd.append("@if exist " + BUILD_DIR_PREFIX + build_type + " @rd /s /q " + BUILD_DIR_PREFIX + build_type);
	#else
	cmd.append("rm -r -f " + BUILD_DIR_PREFIX + build_type);
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

int main(int argc, char** argv)
{
   	std::string command;
   	std::string build_type;
	
	if (argc > 1) command = argv[1];
	if (argc > 2) build_type = argv[2];
	
	if (!command.empty() && build_type.empty()) build_type = DEFAULT_BUILD_TYPE;
	
	system_commands cmd;
	int retval;

	if (command == "clean")
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
			std::cout << "ERROR Invalid command: " << command << std::endl;
			return 1;
		}
	}

	std::system(cmd);
	
	return 0;
}
