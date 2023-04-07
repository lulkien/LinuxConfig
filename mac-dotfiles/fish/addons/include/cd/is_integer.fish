function is_integer
    if test (count $argv) -gt 1
        echo "is_integer: ??? :D ???"
        return 1
    end
    string match -q -r '^[0-9]+' "$argv"; and return 0; or return 1
end
