class LoginView extends Backbone.View

  el: '#content'

  render: =>
    @$el.html "
      <style>
        #login_wrapper{
          font-size: 200%;
          width:50%;
          margin: 0px auto;
        }
        #login_message{
          margin-top: 20px;
          margin-bottom: 20px;

        }
        #login_form input{
          font-size: 100%;
          display: block;
        }
        #login_form input[type=submit]{
          height: 2em;
        }
      </style>
      <div id='login_wrapper'>
        <div id='login_message'>Please login to continue:</div>
        <form id='login_form'>
          <label for='username'>Username</label>
          <input id='username' name='username'>
          <label for='password'>Password</label>
          <input id='password' name='password' type='password'>
          <input type='submit' value='Login'>
        </form>
      </div>
    "

  events:
    "submit form#login_form": "login"

  # Note this needs hashing and salt for real security
  login: ->
    loginData = $('#login_form').toObject()
    user = new User
      _id: "user.#{loginData.username}"

    user.fetch
      success: =>
        # User exists
        if user.get("password") is loginData.password
          $.cookie('current_user', user.get("username"))
          @callback.success()
        else
          $('#login_message').html "Invalid password or username already taken"
      error: =>
        # User doesn't exist
        $('#login_message').html "#{loginData.username} does not yet exist, creating..."
        user.save {
          username: loginData.username
          password: loginData.password
        },{
          success: =>
            $.cookie('current_user', user.get("username"))
            @callback.success()
        }
    return false
