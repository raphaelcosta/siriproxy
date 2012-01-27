#encoding: utf-8
ActiveAdmin::Dashboards.build do

  section "Últimos Devices" do

    table_for Device.last(5) do |t|
      t.column('Token') { |device| link_to device.token, admin_device_path(device)}
      t.column("Usuário") { |device| link_to device.user.name, admin_user_path(device.user)  if device.user}
    end
  end

  section "Recent Posts" do
    div do
      render 'status' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
    end
  end
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end
