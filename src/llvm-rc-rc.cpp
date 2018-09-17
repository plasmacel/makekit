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
#include <regex>
#include <string>

int main(int argc, char** argv)
{
	const std::regex pattern{ "\\s((\\-\\?)|(\\/\\?)|(\\-c)|(\\/c)|(\\-d)|(\\/d)|(\\-fm)|(\\/fm)|(\\-fo)|(\\/fo)|(\\-g1)|(\\/g1)|(\\-h)|(\\/h)|(\\-i)|(\\/i)|(\\-j)|(\\/j)|(\\-k)|(\\/k)|(\\-l)|(\\/l)|(\\-n)|(\\/n)|(\\-q)|(\\/q)|(\\-r)|(\\/r)|(\\-u)|(\\/u)|(\\-v)|(\\/v)|(\\-x)|(\\/x))", std::regex_constants::icase };

	std::string cmd{ "llvm-rc " };

	for (int i = 1; i < argc; ++i)
	{
		//cmd += std::string{ argv[i] } + ' ';
		cmd.append(argv[i]).append(" ");
	}

	std::system(std::regex_replace(cmd, pattern, " $1 ").c_str());
}
