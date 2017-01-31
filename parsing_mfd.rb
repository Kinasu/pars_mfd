require 'nokogiri'
require 'date'
require 'open-uri'

links = {}
bodys = []
del_var = "При перепечатке и цитировании (полном или частичном) ссылка на РИА \"Новости\" обязательна. При цитировании в сети Интернет гиперссылка на сайт http://ria.ru обязательна."

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
  # и не содержит слова обзор или повтор
  if news_list.include? company
    unless news_list.include?("ОБЗОР:" || "ПОВТОР:")
      links.store("https://mfd.ru#{link}", news_list)
    end
  end
end

# убираем повторы -> to do

file = File.new("data/#{company}.txt", "a:UTF-8")
links.each do |key, value|
  news_link = Nokogiri::HTML(open(key))
  date = news_link.css('.mfd-content-container').css('.mfd-content-datetime').css('.mfd-content-time').text
    if date == ("сегодня")
      date = current_date
    elsif date == ("вчера")
      date = Date.today.prev_day.strftime('%d.%m.%Y').to_s
    end

  head = value

  body = news_link.css('.mfd-content-container').css('div.m-content:nth-child(4)').text
  body = body.gsub(/[А-Я]+\,\s\d+\s\W+\.\s/, "").gsub(/\S+,\s\d+\S+.+\s\/\S+\,\s\S+.\//, "")
  body = body.gsub(/\s\s+/, "\r").gsub(del_var, "\r\n\r\n")

  file.puts date
  file.puts head
  file.puts body

end
file.close
