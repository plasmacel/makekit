//#include <experimental/filesystem>
#include <iostream>
#include <string>

const static std::string BUILD_DIR_PREFIX = "build_";

struct system_command
{
	std::string command;

	void append(const std::string& flag)
	{
		command += ' ' + flag;
	}

	operator const char*() const
	{
		return command.c_str();
	}
};

#ifdef _WIN32
void set_environment(const std::string& host_arch, const std::string& target_arch)
{
	std::string current_target_arch = std::getenv("VSCMD_ARG_TGT_ARCH");
	std::string current_host_arch = std::getenv("VSCMD_ARG_HOST_ARCH");
	
	if ((current_host_arch != host_arch) || (current_target_arch != target_arch))
	{
		std::system("call vcvars64.bat");
	}
}

void set_environment(const std::string& arch)
{
	set_environment(arch, arch);
}
#endif

void config(const std::string& build_type)
{
	std::string cmake_build_type;
    
	if (build_type == "debug")
	{
		cmake_build_type = "Debug";
	}
	else if (build_type == "release_debuginfo")
	{
		cmake_build_type = "RelWithDebInfo";
	}
	else if (build_type == "release")
	{
		cmake_build_type = "Release";
	}
	else if (build_type == "release_minsize")
	{
		cmake_build_type = "RelMinSize";
	}
	else
	{
		std::cout << "ERROR Invalid build type: " << build_type << std::endl;
		return;
	}
	
	std::cout << "Configuring " << build_type << " build..." << std::endl;
	
	// Set environment variables on Windows

	#ifdef _WIN32
	set_environment("x64");
	#endif

	// Run CMake

	system_command command{ "cmake" };
	command.append(".");
	command.append("-GNinja");
	command.append("-B" + BUILD_DIR_PREFIX + build_type);
	
	#ifdef _WIN32
	command.append("-DCMAKE_C_COMPILER:PATH='clang-cl.exe'");
	command.append("-DCMAKE_CXX_COMPILER:PATH='clang-cl.exe'");
	command.append("-DCMAKE_LINKER:PATH='lld-link.exe'");
	command.append("-DCMAKE_RC_COMPILER:PATH='rc.exe'");
	#else
	command.append("-DCMAKE_C_COMPILER:PATH='clang'");
	command.append("-DCMAKE_CXX_COMPILER:PATH='clang++'");
	command.append("-DCMAKE_LINKER:PATH='lld-link'");
	#endif
	
	command.append("-DCMAKE_BUILD_TYPE=" + cmake_build_type);
	
	std::system(command);
}

void make(const std::string& build_type)
{
	// Config or refresh

	config(build_type);
	
	// Make

	std::cout << "Making " << build_type << " build..." << std::endl;

	#ifdef _WIN32
	set_environment("x64");
	#endif
	
	system_command command{ "ninja" };
	command.append("-v");
	command.append("-C " + BUILD_DIR_PREFIX + build_type);
	std::system(command);
}


void clean_all(const std::string& build_type)
{
    //std::experimental::filesystem::path build_dir{ "build_" + build_type };
	
    //if (std::experimental::filesystem::exists(build_dir))
	//{
		std::cout << "Cleaning " + build_type + "..." << std::endl;
        //std::experimental::filesystem::remove_all(build_dir);
	//}
    #ifdef _WIN32
    	system_command command{ "@RD"" };
	command.append("/S");
	command.append("/Q");
	command.append(BUILD_DIR_PREFIX + build_type);
    	std::system(command);
    #else
	system_command command{ "rm -R" };
	command.append(BUILD_DIR_PREFIX + build_type);
    	std::system(command);
    #endif
}

void clean_config(const std::string& build_type)
{
    //std::experimental::filesystem::path cmake_cache{ "build_" + build_type + "/CMakeCache.txt" };
	
    //if (std::experimental::filesystem::exists(cmake_cache))
	//{
		std::cout << "Cleaning " + build_type + " configuration..." << std::endl;
        //std::experimental::filesystem::remove(cmake_cache);
	//}
    
    #ifdef _WIN32
    	system_command command{ "del" };
	command.append(BUILD_DIR_PREFIX + build_type + "\CMakeCache.txt");
        std::system(command);
    #else
	system_command command{ "rm" };
	command.append(BUILD_DIR_PREFIX + build_type + "/CMakeCache.txt");
        std::system(command);
    #endif
}

void clean_make(const std::string& build_type)
{
	system_command command{ "ninja" };
	command.append("-C " + BUILD_DIR_PREFIX + build_type);
	command.append("-t clean");
	std::system(command);
}

void refresh(const std::string& build_type)
{
	config(build_type);
}

void reconfig(const std::string& build_type)
{
	clean_config(build_type);
	config(build_type);
}

void remake(const std::string& build_type)
{
	clean_make(build_type);
	make(build_type);
}

int main(int argc, char** argv)
{
   	std::string command;
   	std::string build_type;

	if (argc > 1) command = argv[1];
	if (argc > 2) build_type = argv[2];

	if (build_type.empty()) build_type = "release";
    
	if (command == "clean")
	{
		clean_all(build_type);
	}
	else if (command == "config")
	{
		config(build_type);
	}
	else if (command == "make")
	{
		make(build_type);
	}
	else if (command == "reconfig")
	{
		reconfig(build_type);
	}
	else if (command == "refresh")
	{
		refresh(build_type);
	}
	else if (command == "remake")
	{
		remake(build_type);
	}
	else
	{
		if (command.empty())
		{
			std::cout << "No command specified." << std::endl;
		}
		else
		{
			std::cout << "ERROR Invalid command: " << command << std::endl;
			return 1;
		}
	}
     

	return 0;
}
