Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name, :null=>false
      String :uid, :null=>false
      String :gender
      String :from
      String :member
      String :bio
      String :tag
      String :birthday
      String :identification #认证
      Time :created_at
    end

    create_table(:user_history) do
      primary_key :id
      foreign_key :user_id, :users
      #String :name 暂不记录名字的修改
      String :level #级别
      Integer :tweet_num
      Integer :follow_num
      Integer :follower_num
      Integer :group_num
      Integer :page_num
      Time :created_at
    end

    create_table(:tweets) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :parent_id, :tweets
      String :tid
      String :content, :null=>false
      Boolean :isRetweet #是否为转发
      Boolean :hasPic #是否含图片
      String :tweet_url #当前地址
      String :comment_url #评论地址
      String :picture_url #图片地址
      String :tweet_by #客户端
      String :tag #标签
      Time :tweet_at
    end

    create_table(:tweet_history) do
      Boolean :isDeleted, :default=>false #是否被删除
      Integer :support_num
      Integer :retweet_num
      Integer :comment_num
      Time :created_at
    end

    create_table(:tasks) do
      primary_key :id
      String :url, :null=>false
      #String :name
      Integer :target_id
      String :task_type #task_type include: user, tweet, origintweet, user_tag
      Integer :error_count, :default=>0
      Integer :update_count, :default=>0
      Boolean :done, :default=>false
      Time :created_at
      Time :run_at
    end

  end
end
