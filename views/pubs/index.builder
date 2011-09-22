xml.instruct!
xml.pubs do
  pubs.each do |pub|
    xml.pub(href: "/pubs/#{pub.id}") do
      xml.name pub.name
      xml.description pub.description
      xml.location do
        xml.latitude pub.lat
        xml.longitude pub.lon
      end
    end
  end
end

