class PostsController < ApplicationController
  # before_action은 하나의 액션을 실행하기 전에 해당 메소드를 실행.
  # 컨트롤러.. filter
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: :index

  def index
    # 모든 것을 보여주는 곳...
      @posts = Post.where("title LIKE ?", "%#{params["q"]}%") #검색
  end

  def new
  end

  def create
    current_user.posts.create(post_params)
    # post = Post.new
    # post.title = params[:title]
    # post.content = params[:content]
    # post.save
    redirect_to '/'
  end

  # Read
  def show
    # @post = Post.find(params[:id]) #코드 중복 방지
  end

  # update
  def update
    # @post = Post.find(params[:id]) #코드 중복 방지
    @post.update(post_params)
    redirect_to "/posts/#{@post.id}"
  end

  def edit
    # @post = Post.find(params[:id]) #코드 중복 방지
  end

  # delete
  def destroy
    @post.destroy
    redirect_to '/'
    # @post = Post.find(params[:id])
  end

  # private 위에는 public이라서 url로 요청오면 그것을 받아서 뷰를 보여준다.
  private
  # private은 해당 컨트롤러(PostsController)에서만 사용가능함.
  # 객체에서 private 속성을 가지면.. 클래스 내부에서만 접근이 가능했었고,
  # 이외의 상속받은 클래스나 객체 인스턴스에서도 접근이 불가능했음.
  def set_post
    @post = Post.find(params[:id])
  end

# strong parameter
  def post_params
    params.require(:post).permit(:title, :content, :postimage)
    #  이런 해쉬를 리턴해줌 : "post"=>{"title"=>"asdf", "content"=>"q1111"}
  end
end
