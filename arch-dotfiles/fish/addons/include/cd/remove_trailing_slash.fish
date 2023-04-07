function remove_trailing_slash
    if test (string length $argv) -gt 1
        while string match -q -r '/$' $argv
            set argv (string sub -s 1 -l (math (string length $argv) - 1) $argv)
        end
    end
    echo $argv
end
