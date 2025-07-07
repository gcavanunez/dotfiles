---@class LaravelProvider
local laravel_provider = {}

---@param app LaravelApp
function laravel_provider:register(app)
  app:bind('model_info_view', 'user.plugins.laravel.model_info_view')
end

---@param app LaravelApp
function laravel_provider:boot(app) end

return laravel_provider
