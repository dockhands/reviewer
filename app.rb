gem 'sinatra', '1.4.7'
require 'sinatra'
# require 'sinatra/reloader'
require "nokogiri"
require 'httparty'
# require "pry"
require "json"
require "csv"
require 'open-uri'
gem 'font-awesome-less'

get '/' do
  "hello world"
  erb(:index, { layout: :app_layout })
end

post '/' do
 #get the input movie_input
  # params => {"title"=>"my blog post title", "body"=>"the blog post body"}
  movie_input = params[:movie_input]
#  get movie input and change to imdb link

#this method is used to return a response from the user, into a google search,  and return an IMdB link
imdb_search = "http://www.imdb.com/find?ref_=nv_sr_fn&q="
movie = movie_input
movie = movie.gsub(" ", '+')
imdb_movie = imdb_search + movie

# trying to get the first URL
     page = Nokogiri::HTML(open(imdb_movie))
    link = page.xpath('//*[@id="main"]/div/div[2]/table')
    #link1 = page.xpath('//*[@id="main"]/div/div[2]/table/tbody/tr')
    #'//*[@id="main"]/div/div[2]/table/tbody/tr[1]/td[2]/a'
    link = link.css('td.result_text').inner_html
    # link = link.xpath('//*[@id="main"]/div/div[2]/table/tbody/tr[1]/td[2]/a')

    p "this is the first link is " + link
    # link = link.attributes["a"].value.to_s
    link = link.scan(/"([^"]*)"/).to_s
    title =  link.gsub("[", "").gsub('"', "").gsub(']', "").split("?",2)[0]



   final_imdb_link = "http://www.imdb.com/" + title

  p "final_imdb_link = " + final_imdb_link



  #======= GET DIRECTOR METHOD

  def get_movie_info(movie_title)
    #page = HTTParty.get('http://www.imdb.com/title/tt0119081/')
    page = HTTParty.get(movie_title)
    # this is where we transform our http response into a nokogiri object so that we can parse it
    parse_page = Nokogiri::HTML(page)
    #now we grab the HTML content we want
    #GET TITLE
    movie_name = parse_page.xpath('//h1').text.strip
    p "this is the movie_name " + movie_name
    director = parse_page.xpath('//*[@id="title-overview-widget"]/div[3]/div[2]/div[1]/div[2]/span[1]/a/span')

    # director = parse_page.css('.credit_summary_item').text.gsub("\n",'').gsub("Director:","").strip
    p "this is the direcor " + director
    actors = []
        actor_1 = parse_page.xpath('//*[@id="title-overview-widget"]/div[3]/div[1]/div[4]/span[1]/a/span').inner_html
        actor_2 = parse_page.xpath('//*[@id="title-overview-widget"]/div[3]/div[1]/div[4]/span[2]/a/span').inner_html
        actor_3 = parse_page.xpath('//*[@id="title-overview-widget"]/div[3]/div[1]/div[4]/span[3]/a/span').inner_html
        actors = [actor_1, actor_2, actor_3]
          p "this the main actor... "
           p  actors

        characters = []
      #  char_1 = parse_page.xpath('//*[@id="titleCast"]/table/tbody/tr[16]/td[4]/div/a')
        char_1 = parse_page.xpath('//*[@id="titleCast"]/table/tbody/tr[2]/td[4]/div/a').inner_html
        char_2 = parse_page.xpath('//*[@id="titleCast"]/table/tbody/tr[2]/td[4]').inner_html
      #  character_2 = parse_page.xpath('//*[@id="titleCast"]/table/tbody/tr[3]/td[4]/div/a').inner_html
      #  character_3 = parse_page.xpath('//*[@id="titleCast"]/table/tbody/tr[4]/td[4]/div/a').inner_html
      #  characters = [character_1, character_2, character_3]
          p "this the main charactrs... "
          p char_2


          rating = parse_page.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[1]/div[1]/div[1]/strong/span').inner_html
          p "this is the rating"
          p rating
          new_rating = (rating.to_f)/10
          p "this is the new rating"
          p new_rating
    #GET TIME
           time = parse_page.xpath('//time').text.gsub("\n",'').strip[-7, 7]
         p "this the time ... "
         p  time
  #GET plot
         plot = parse_page.xpath('//*[@id="titleStoryLine"]/div[1]/p').inner_html.gsub("\n"," ")
         plot = plot.split('<em', 2)
         plot = plot[0].split('.',2)
         # plot_words = plot[1].scan(/\w+ \w+/)

   #GET keywords
         keywords = []
         kw_1 = parse_page.xpath('//*[@id="titleStoryLine"]/div[2]/a[1]/span').inner_html
         kw_2 = parse_page.xpath('//*[@id="titleStoryLine"]/div[2]/a[2]/span').inner_html
         kw_3 = parse_page.xpath('//*[@id="titleStoryLine"]/div[2]/a[3]/span').inner_html
         kw_4 = parse_page.xpath('//*[@id="titleStoryLine"]/div[2]/a[4]/span').inner_html
         keywords =  [ kw_1,kw_2, kw_3, kw_4]

         tagline = parse_page.xpath('//*[@id="titleStoryLine"]/div[3]').text
         tagline =  tagline.gsub("\n"," ")
         tagline = tagline.rpartition("Taglines:")[2]
         tagline = tagline.split("See more")[0]


          #get review
            review_page = movie_title.split('?', 2)
             review_page = review_page[0] << "reviews?ref_=tt_urv"

             page = HTTParty.get(review_page)
             # this is where we transform our http response into a nokogiri object so that we can parse it
             parse_page = Nokogiri::HTML(page)
             review = parse_page.xpath('//*[@id="tn15content"]/p[10]').text.gsub("\n"," ")


    movie_info = {
            time: time,
            actors: actors,
            plot: plot,
            keywords: keywords,
          #  characters: characters,
            director: director,
            movie_name: movie_name,
            review: review,
            new_rating: new_rating,
            tagline: tagline,
          }

  rescue
  #   bad_link(error)
  end
 @movie_info = get_movie_info(final_imdb_link)

  #Get movie review from dandywarhos.com

  #review_link = "https://www.dandywarhols.com/news/band/courtney/courtneys-one-sentence-movie-reviews/"
  # def get_movie_review(review_website)
  #       #page = HTTParty.get('http://www.imdb.com/title/tt0119081/')
  #       p "get movie review is running"
  #       page = HTTParty.get(review_website)
  #       # this is where we transform our http response into a nokogiri object so that we can parse it
  #       parse_page = Nokogiri::HTML(page)
  #       number = rand(1..249).to_s
  #       p "This isthe random number " + number
  #
  #       review = parse_page.xpath('//*[@id="tm-content"]/article/table['+number+']/tbody/tr/td[2]/p[3]').text
  #       #p "this is the moview_review taken from warhols " + movie_review
  #       movie_review = {
  #         review: review,
  #       }
  # end

  # @movie_review = get_movie_review(review_link)


  erb(:index, { layout: :app_layout })
end
