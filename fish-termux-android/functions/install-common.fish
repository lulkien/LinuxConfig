function install-common
    cd ~/working/source-code/AppCommon    
    git clean -f -d    
    git reset --hard HEAD    
    git pull    
    sudo cp * /usr/local/oecore-x86_64/sysroots/x86_64-oesdk-linux/usr/lib/x86_64-oe-linux/gcc/x86_64-oe-linux/5.2.0/include 
end


