#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RESET   "\x1b[0m"

#ifdef DEBUG
  #define _L(fmt, ...) NSLog((@"<Uniformity> " ANSI_COLOR_GREEN "%s" ANSI_COLOR_RESET " [Line %d] " ANSI_COLOR_RED fmt ANSI_COLOR_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
  #define _L(...)
#endif

#define kAppId CFSTR("co.pNre.uniformity")
