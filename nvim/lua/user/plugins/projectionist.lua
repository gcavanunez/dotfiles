return {
  'tpope/vim-projectionist',
  dependencies = 'tpope/vim-dispatch',
  config = function()
    vim.g.projectionist_heuristics = {
      artisan = {
        ['*'] = {
          start = 'php artisan serve',
          console = 'php artisan tinker',
        },
        ['app/*.php'] = {
          type = 'source',
          alternate = {
            'tests/Unit/{}Test.php',
            'tests/Feature/{}Test.php',
          },
        },

        ['tests/Feature/*Test.php'] = {
          type = 'test',
          alternate = 'app/{}.php',
        },
        ['tests/Feature/Controllers/*Test.php'] = {
          type = 'test',
          alternate = 'app/Http/Controllers/{}.php',
        },
        ['tests/Unit/*Test.php'] = {
          type = 'test',
          alternate = 'app/{}.php',
        },
        ['app/Models/*.php'] = {
          type = 'model',
        },
        ['app/Http/Controllers/*.php'] = {
          type = 'controller',
          alternate = {
            'tests/Feature/Controllers/{}Test.php',
            'tests/Feature/{}Test.php',
          },
        },
        ['routes/*.php'] = {
          type = 'route',
        },
        ['database/migrations/*.php'] = {
          type = 'migration',
        },
      },
      ['src/&composer.json'] = {
        ['src/*.php'] = {
          type = 'source',
          alternate = {
            'tests/{}Test.php',
          },
        },
        ['tests/*Test.php'] = {
          type = 'test',
          alternate = 'src/{}.php',
        },
      },
      ['app/&composer.json'] = {
        ['app/*.php'] = {
          type = 'source',
          alternate = {
            'tests/{}Test.php',
          },
        },
        ['tests/*Test.php'] = {
          type = 'test',
          alternate = 'app/{}.php',
        },
      },
    }
  end,
}
