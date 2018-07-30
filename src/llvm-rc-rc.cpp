#include <cstdlib>
#include <regex>
#include <string>

int main(int argc, char** argv)
{
	const std::regex pattern{ "((\\-D)|(\\/D)|(\\-I)|(\\/I))" };

	std::string cmd{ "llvm-rc " };

	for (int i = 1; i < argc; ++i)
	{
		//cmd += std::string{ argv[i] } + ' ';
		cmd.append(argv[i]).append(" ");
	}

	std::system(std::regex_replace(cmd, pattern, "$1 ").c_str());
}
