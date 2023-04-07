function __qPrintColor
    if test (count $argv) -lt 1
        return 1
    else
        set_color $argv[1]
        echo $argv[2..-1]
        set_color normal
    end
end
