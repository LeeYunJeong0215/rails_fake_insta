### 1. CRUD 끝내기 (non scaffold)

**RESTful** 하게 짜기! (posts 컨트롤러, post 모델!)

RESTful이란, 주소창(url)을 통해서 자원(리소스)과 행위(HTTP Verb)를 표현하는 것.

[가장 깔끔한 설명](http://meetup.toast.com/posts/92)

[routes](#1. routes.rb)

#### 0. 기본 사항

 - `git` 셋팅(git init부터)
 - C/R/U/D 마다 **commit** 하기
 - `posts` 컨트롤러와 `post` 모델만!

# 1. routes.rb

```ruby
  # index
  get '/posts' => 'posts#index'
  # Create
  get '/posts/new' => 'posts#new'
  post '/posts'=> 'posts#create'
  # Read
  get '/posts/:id' => 'posts#show'
  # Update
  get '/posts/:id/edit' => 'posts#edit'
  put '/posts/:id' => 'posts#update'
  # Delete
  delete '/posts/:id' => 'posts#destroy'
```

2. controller

  * [filter](http://guides.rorlab.org/action_controller_overview.html#%ED%95%84%ED%84%B0)

  ```ruby
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  private

  def set_post
    @post = Post.find(params[:id])
  end
  ```

  * [strong parameters](http://guides.rorlab.org/action_controller_overview.html#strong-parameters)

  ```ruby
  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
  ```

3. view - form_tag / form_for
  * [폼 헬퍼](http://guides.rorlab.org/form_helpers.html)

### 2. scaffolding.. 편하게 CRUD

1. `routes.rb`

```ruby
  resources :posts
```

2. `scaffold` 명령어

```console
$ rails g scaffold post title:string content:text
```

`posts` 컨트롤러와 `post` 모델을 만들어줌! 코드도 겁나 많음..


### 3. [파일업로드](https://github.com/carrierwaveuploader/carrierwave)

    1. `gemfile`

  ```ruby
  gem carrierwave
  ```

  ```console
  $ bundle install
  ```
    2. 파일업로더 생성

  ```console
  $ rails generate uploader Avatar
  ```

  3. 서버 작업

    * migration : string 타입의 column 추가

    * `post.rb`

      ```ruby
      mount_uploader :컬럼명, AvatarUploader
      ```

    * `posts_controller.rb`

      ```ruby
      # strong parameter에 받아주거나, create 단계에서 사진 받을 준비
      ```

  4. `new.html.erb`

  ```html
  <form enctype="multipart/form-data">
    <input type="file" name="post[postimage]">
  </form>

  <%= form_tag ("/posts", method: "post", multipart: true) do %>
    <%= file_field_tag("post[postimage]") %><br />
  <% end %>
  ```

### 3-1. 사진 크기 조절하여 저장

  `gem mini_magick`

### 4. 인스타처럼 꾸미기(카드형 배치)



## 20180104

### 1. devise로 회원가입 기능 구현하기
참고사이트 : [devise](https://github.com/plataformatec/devise)

#####1. 기초 시작하기
- `Gemfile`에 `gem devise(divise 추가 후) `	`bundle install` 하기

- devise를 설치함
```console
$ rails generate devise:install

주요하게 만들어지는 것들 : devise.rb
```
- `app/views/layouts/application.html.erb`에 추가
```HTML
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>
```

- User 모델 만들기 with devise

```console
$ rails g devise User(모델명)

주의) 미리 모델을 만들지 말 것.
```

##### 2. 추가 내용

- 사용 가능한 helper

  - current_user : 로그인 되어 있으면, 해당 user를 불러올 수 있다.
  - user_sign_in? : 로그인 되어있는지 => return boolean

- 로그인 해야 페이지 보여주는 방법(`posts_controller.rb`)

  ```ruby
  before_action :authenticate_user!, except: :index
  ```

- view에서 로그인해야 글쓰기 및 기타기능 가능하도록 하는 방법(`application.html.erb`)

  ```erb
  <% if user_signed_in? %>
    <li>
    <%= current_user.email %>님
    <%= link_to('Logout', destroy_user_session_path, method: :delete) %>
    </li>
  <% else %>
    <li>
    <%= link_to('Login', new_user_session_path)  %>
    <%= link_to('회원가입', new_user_registration_path) %>
    </li>
  <% end %>
  ```

- devise view 파일 가져오기(커스터마이징)

  ```console
  $ rails g devise:views
  ```

- devise controller 커스터마이징 하기

  ```console
  $ rails g devise:controllers users
  ```

  `users/` 많은 컨트롤러가 생김.

  **반드시 `routes.rb`수정**

  ```ruby
  devise_for :users, controllers:{
    sessions: 'users/sessions'
    }
  ```

-  커스터마이징 column(username 추가)

  1) `migration` 파일에 원하는 대로 만들기(db에 `username`추가 후 `db:migrate`)

  2) 해당 view에서 input박스 만들기(`devise/registrations/new.html.erb`)

  3) strong parameter 설정(컨트롤러 직접 가능 / `application_controller.rb`에서도 가능)

  ```ruby
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    end
  end

  ```

  ```ruby
  방법2)
  # frozen_string_literal: true

  class Users::RegistrationsController < Devise::RegistrationsController
     before_action :configure_sign_up_params, only: [:create]
     before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    end

    If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    end

    The path used after sign up.
    def after_sign_up_path_for(resource)
      super(resource)
    end

    The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(resource)
      super(resource)
    end
  end

  ```



####3. admin만 볼 수 있는 페이지 만들기

참고페이지 : https://github.com/plataformatec/devise/wiki/How-To:-Add-an-Admin-Role

- ```console
  $ rails generate devise:views
  ```

- db에 column 추가

  ```console
  $ rails generate migration add_admin_to_users admin:boolean
  ```

- `fake_insta\db\migrate\20180104041610_add_admin_to_users.rb`에 추가
  ```ruby
    def change
        add_column :users, :admin, :boolean, default:false
    end
  ```

- 관리자 계정만들기

     - 홈페이지에서 회원가입
     - console에 입력

     ```console
     $ rails c
     $ User.first.update(admin:true)
     -> first는 저장위치를 나타내는것으로 user의 첫번째 라는 의미.
     ```

- `app\controllers\users_controller.rb`
 ```ruby
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    @users = User.all
  end

  private

  def is_admin?
    redirct_to '/' and return unless current_user.admin?
  end
end
 ```

- `app\views\users\index.html.erb`
 ```ruby
<% @users.each do |user| %>
<p><%= user.id %></p>
<p><%= user.email %></p>
<p><%= user.username %></p>
<hr />
<% end %>
 ```

- `routes.rb`
  ```ruby
    get '/users/index' => 'users#index'
  ```

  ​

###2. cancancan 사용(권한 부여)

참고사이트 : [cancancan](https://github.com/CanCanCommunity/cancancan)

##### 1. 시작하기

- `Gemfile` 에 `gem 'cancancan', '~> 2.0'` 추가

- ```console
  $ rails g cancan:ability
  ```




#####2. 글 수정&삭제시 권한 확인

참고사이트 : https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

- `model/ability.rb`
```ruby
include CanCan::Ability

def initialize(user)
  can :read, :all  # permissions for every user, even if not logged in
  if user.present?  # additional permissions for logged in users (they can manage their posts)
    can :manage, Post, user_id: user.id
    if user.admin?  # additional permissions for administrators
      can :manage, :all
    end
  end
```

- `application_controller.rb` 추가

  ```ruby
  before_action :configure_permitted_parameters, if: :devise_controller?

    rescue_from CanCan::AccessDenied do |exception|
      flash[:alert] = "권한없지롱~"
      redirect_to '/'
      # respond_to do |format|
      #   format.json { render nothing: true, :status => :forbidden }
      #   format.xml { render xml: "...", :status => :forbidden }
      #   format.html { redirect_to main_app.root_url, :alert => exception.message }
      end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    end
  end
  ```

  ​

- `app\controllers\posts_controller.rb`에 authorize! 만 추가함.

  참고사이트:https://github.com/CanCanCommunity/cancancan/wiki/Authorizing-controller-actions

  방법1)

  ```ruby
    def show
       @post = Post.find(params[:id]) #코드 중복 방지
    end

    # update
    def update
      # @post = Post.find(params[:id]) #코드 중복 방지
      authorize! :update, @post
      @post.update(post_params)
      redirect_to "/posts/#{@post.id}"
    end

    def edit
      authorize! :update, @post
      # @post = Post.find(params[:id]) #코드 중복 방지
    end

    # delete
    def destroy
      authorize! :destroy, @post
      @post.destroy
      redirect_to '/'
      # @post = Post.find(params[:id])
    end
  ```

  방법2) 이것만 추가(각각 authorize를 적어주지 않아도 되는 코드)

  ```ruby
  load_and_authorize_resource param_method: :post_params
  ```




##### 3. 작성자가 아니면 수정/삭제버튼도 안보이게 하기

- `app\views\posts\show.html.erb` 에 이렇게 코드 수정

```ruby
<% if can? :update, @post %>
<p><a href="/posts/<%=@post.id%>/edit">수정</a></p>
<% end %>
<%if can? :destroy, @post %>
<p><a href="/posts/<%=@post.id%>" data-method="delete" data-confirm="삭제할래?">삭제</a></p>
<% end %>

```



cancancan보다 더 자유도는 높으나 쓰기는 어려운 gem : [pundit](https://github.com/varvet/pundit)



<교재 참고>

* 3장 전부
* 4장 : 4.1(form_tag, form_for) , 4.7(layouts)
* 5장 : 쿼리메소드, 5.8 마이그레이션
* 6장 : 6.1, 6.4.3(session), 6.4.4(flash), 6.5(필터)*** 6.6 (application 컨트롤러)
* 7장 : 7.1(RESTful)
