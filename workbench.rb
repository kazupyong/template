require 'bundler'
require 'active_record'
require 'sinatra/twitter-bootstrap'
Bundler.require
Dotenv.load

I18n.available_locales = [ :ja, :en ]
I18n.backend.load_translations

#database configuration
ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(:development)


class Translations < ActiveRecord::Base
end
class Files < ActiveRecord::Base
end

class Workbench < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    @title = 'Index'
    @files = Files.all
    slim :index
  end

  get '/files' do
    @title = 'ファイル一覧'
    @files = Files.all
    slim :files
  end

  get '/list' do
    @title = 'リスト'
    @file = Files.find(params[:id])
    redirect to('/') unless File.exist?(@file.file_path)
    @translations = Translations.where(file_id: @file.id)
    japanese = []
    @translations.each do |translation|
      japanese.push(translation.translate_key)
    end
    @ja_translations = Translations.where(locale: "ja").where(translate_key: japanese).pluck(:translate_key, :translate_value).to_h
    slim :list
  end

  get '/all' do
    @title = '全体'
    if params['query'].nil?
      @translations = Translations.where(locale: "en")
    else
      @translations = Translations.where(locale: "en").where("translate_value LIKE ? ", '%' + params['query'] + '%')
    end
    japanese = []
    @translations.each do |translation|
      japanese.push(translation.translate_key)
    end
    @ja_translations = Translations.where(locale: "ja").where(translate_key: japanese).pluck(:translate_key, :translate_value).to_h
    slim :list
  end

  post '/update' do
    translate = Translations.find(params['id'])
    translate.translate_value = params['translate_value']
    translate.save
    p translate.translate_value
  end

  post '/files/reload' do
    Dir[File.join(File.dirname(__FILE__),'data', 'translations', '**', '*.yml').to_s].each do |file_path|
      file = Files.find_or_create_by(file_path: file_path, locale: detect_locales(file_path))
      file.save
      translations = hash_to_object_style(YAML.load_file(file.file_path))
      translations.each_pair do |key, value|
        translate = Translations.find_or_create_by(translate_key: key, file_id: file.id)
        translate.translate_value = value
        translate.locale          = file.locale
        translate.save
      end
    end
    redirect to('/')
  end
end

def hash_to_object_style(translations, key = nil, values = {})
  case translations
    when Hash
      translations.inject({}) do |hash, (k, v)|
        k = key.to_s + '.' + k.to_s unless key.nil? || (I18n.available_locales.include?(key.to_sym))
        values[k] = v unless v.kind_of?(Hash)
        hash[k] = hash_to_object_style(v, k, values) # Hash の値を再帰的に処理
        hash
      end
    else
      translations
  end
  values
end

def detect_locales(file_path)
  locale = 'ja'
  I18n.available_locales.each do |localeset|
    locale = localeset.to_s if file_path.to_s.include?("#{localeset.to_s}.")
  end
  locale
end