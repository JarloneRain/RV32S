#ifndef __LOGGER_H
#define __LOGGER_H

#include <cstdarg>
#include <cstdio>
#include <string>

class Logger {
public:
    enum LOG_COLOR_ENUM {
        DEFAULT = 0,
        BLACK,
        RED,
        GREEN,
        YELLO,
        BLUE,
        PURPLE,
        CYAN,
        WHITE
    };
    template <LOG_COLOR_ENUM FONT_COLOR = DEFAULT, LOG_COLOR_ENUM BACK_COLOR = DEFAULT>
    const Logger &Log(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);
        std::string font_color = ";" + std::to_string(29 + FONT_COLOR);
        std::string back_color = ";" + std::to_string(39 + BACK_COLOR);
        if constexpr(FONT_COLOR == DEFAULT)
            font_color = "";
        if constexpr(BACK_COLOR == DEFAULT)
            back_color = "";

        printf("%s", ("\033[1" + font_color + back_color + "m").c_str());
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &RedFont(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;31m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &RedBack(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;41m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &GreenFont(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;32m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &GreenBack(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;42m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &YellowFont(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;33m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &YellowBack(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;43m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &BlueFont(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;34m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
    const Logger &BlueBack(const char *fmt, ...) const {
        va_list args;
        va_start(args, fmt);

        printf("\033[1;44m");
        vprintf(fmt, args);
        printf("\033[0m\n");

        va_end(args);
        return *this;
    }
};

#endif