function __qPrintColorB
    if test (count $argv) -lt 1
        return 1
    else
        set_color -o $argv[1]
        echo $argv[2..-1]
        set_color normal
    end
end
