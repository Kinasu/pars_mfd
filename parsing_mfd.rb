require 'open-uri'
require 'nokogiri'

links = []

bodys = []
#введите название компании
puts "Какую компанию смотрим?"
company = gets.chomp
company.chop if company.match(/ь$/)

#введите номер айди компании
puts "Введите номер компании: "
id = gets.to_i

#введите дату последнего просмотра
puts "Введите дату"
start_date = gets.chomp
#сегодняшнее число
current_date = Date.today.strftime('%d.%m.%Y').to_s

page = Nokogiri::HTML(open("https://mfd.ru/news/company/view/?id=#{id}&from=#{start_date}&to=#{current_date}"))

#выводим все заголовки новостей этой компании
page.css('.mfd-body-container').css('.mfd-content-container').css('#issuerNewsList').css('a').each do |n|
  news_list = n.text.strip
  link = n.attributes['href'].value

  #добавляем ссылки в массив, если название заголовка содержит переменную company
  links << "https://mfd.ru#{link}" if news_list.include? company

end

file = File.new("./#{company}.txt", "a:UTF-8")
links.each do |news|
  news = Nokogiri::HTML(open(news))
  date = news.css('.mfd-content-container').css('.mfd-content-datetime').css('.mfd-content-time').text
  head = news.css('.mfd-content-container').css('.mfd-content-title').text
  news.css('.mfd-content-container').css('div.m-content:nth-child(4)').css('p').each do |i|
    body = i.text
    bodys << body
  end
  bodys.pop(2)
  bodys.join(", ")
  file.puts date
  file.puts
  file.puts head
  file.puts
  file.puts bodys
  file.puts
end
file.close
