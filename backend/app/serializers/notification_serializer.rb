class NotificationSerializer
  include Alba::Resource

  attributes :id, :title, :body, :category, :read_at,
             :notifiable_type, :notifiable_id, :created_at

  attribute :read do |notification|
    notification.read?
  end
end
