module Gamefic::Image
  attr_accessor :image
end

class Gamefic::Entity
  include Image
end

module Gamefic::ImageViewer
  def show_image filename
    tell "<figure><img src=\"media/#{filename}\" /></figure>"
  end
end

class Gamefic::Character
  include ImageViewer  
end
