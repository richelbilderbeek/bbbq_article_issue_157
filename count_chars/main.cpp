#include <algorithm>
#include <cassert>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

int count_char(const std::string& s, const char c)
{
  return std::count(s.begin(), s.end(), c);
}

int count_char(const std::vector<std::string>& text, const char c)
{
  int sum = 0;
  for (const auto& s: text) sum += count_char(s, c);
  return sum;
}

///Determines if a filename is a regular file
///From http://www.richelbilderbeek.nl/CppIsRegularFile.htm
bool IsRegularFile(const std::string& filename)
{
  std::fstream f;
  f.open(filename.c_str(),std::ios::in);
  return f.is_open();
}

///FileToVector reads a file and converts it to a std::vector<std::string>
///From http://www.richelbilderbeek.nl/CppFileToVector.htm
std::vector<std::string> file_to_vector(const std::string& filename)
{
  assert(IsRegularFile(filename));
  std::vector<std::string> v;
  std::ifstream in(filename.c_str());
  for (int i=0; !in.eof(); ++i)
  {
    std::string s;
    std::getline(in,s);
    v.push_back(s);
  }
  return v;
}

int main()
{
  assert(count_char(std::string("ABC"), 'A') == 1);
  assert(count_char(std::string("ABC"), 'B') == 1);
  assert(count_char(std::string("ABC"), 'D') == 0);
  const auto text = file_to_vector("sequences.txt");
  for (int i = 0; i != 26; ++i)
  {
    const char c = 'A' + i;
    std::cout << c << "," << count_char(text, c) << '\n';
  }
}

