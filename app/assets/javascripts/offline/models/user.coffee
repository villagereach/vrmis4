class Models.User extends Backbone.Model
  login: (password) ->
    return false unless password is @get('accessCode')
    @trigger 'login'
    true
