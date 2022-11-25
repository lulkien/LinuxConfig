-- Make sure packer has been installed
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end
local packer_bootstrap = ensure_packer()

-- Packer startup
return require('packer').startup(function()
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Intellisense
    use 'jiangmiao/auto-pairs'

    -- Search
    use 
    {
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.0',
            requires = {
                'nvim-lua/popup.nvim',
                'nvim-lua/plenary.nvim',
                'telescope-fzf-native.nvim',
            },
            wants = {
                'popup.nvim',
                'plenary.nvim',
                'telescope-fzf-native.nvim',
            },
            setup   = function()
                require('config.telescope_setup')
            end,
            config  = function()
                require('config.telescope_config')
            end,
            cmd     = 'Telescope',
            module  = 'telescope',
        },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            run = 'make',
        }
    }

    -- Themes, Icons, Interface
    use 
    {
        'feline-nvim/feline.nvim',
        config = function()
            --require('config.feline_toufyx')
            -- require('config.feline_crivotz')
            require('config.feline')
        end
    }

    use 
    {
        'joshdick/onedark.vim',
        config = function()
            require('config.theme_config')
        end
    }

    -- For bootstrap
    if packer_bootstrap then
        require('packer').sync()
    end
end)

