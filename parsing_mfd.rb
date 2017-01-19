require 'open-uri'
require 'nokogiri'

links = []
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
  links << "https://mfd.ru#{link}" if news_list.include? company

end

file = File.new("data/#{company}.txt", "a:UTF-8")
links.each do |news|
  news = Nokogiri::HTML(open(news))
  date = news.css('.mfd-content-container').css('.mfd-content-datetime').css('.mfd-content-time').text
  head = news.css('.mfd-content-container').css('.mfd-content-title').text
  body = news.css('.mfd-content-container').css('div.m-content:nth-child(4)').text.gsub(/[А-Я]+\,\s\d+\s\W+\.\s/, "").gsub(/\s\s+/, "\r")
  #to do сегодня вчера и при перепечатке.. заменить
  file.puts date
  file.puts head
  file.puts body
end
file.close

if File.exist? ("data/#{company}.txt")
  file = File.open("data/#{company}.txt", "r:UTF-8")
  @filelines = file.readlines
  File.delete("data/#{company}.txt")
  # file.close
  # @filelines.map! {|s| s.gsub("\r\n", "")}
else
  puts "Файл не найден"
end

file = File.new("data/#{company}.txt", "a:UTF-8")

@count_line = 1
@cikl = 0
@size = @filelines.size

while @cikl <= @size
  # puts "цикл строк: #{@count_line}"
  # puts "длинна массива: #{@size}"
  # puts "просто цикл для цикла: #{@cikl}"
  header = @filelines[@count_line]

  double = @filelines.each_index.select { |i| @filelines[i] == header }

  x = double.length
    if x > 1
      e = [double.last-1.to_i, double.last-1.to_i, double.last-1.to_i]
      e.each do |del|
        @filelines.delete_at(del)
      end
    end
      @count_line += 3
      @size -= 3
      @cikl += 1
end

file.puts(@filelines)
file.close
