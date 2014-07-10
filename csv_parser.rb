class CSVParser

  # 正規表現版
  def self.parse_by_regrex(csv)
    if csv !~ /\n\Z/
      csv += "\n"
    end

    result = []
    row = []
    csv_regrex = /
( # 1
\A # 先頭
(?:
  ([^,"\r\n]+)| # ダブルクオートで囲まれていない場合 2
  (?:"((?:[^"]|"")*)")| # ダブルクオートで囲まれている場合 3
  () # 空文字の時 4
)
(\n|,) # 改行かカンマ 5
)
/x
    while pos = csv =~ csv_regrex
      cell = nil
      skip_length = pos + $1.length
      delimiter = $5
      if !$2.nil?
        cell = $2
      elsif !$3.nil?
        cell = $3
      else
        cell = ""
      end

      row.push cell.gsub(/""/,'"')
      if delimiter == "\n"
        result.push row
        row = []
      end
      csv = csv[skip_length..-1]
    end
    result
  end

  # 走査版
  def self.parse_by_scan(csv)
    if csv[-1] != "\n"
      csv += "\n"
    end
    token = ""
    quote_flag = false
    quote_count = 0
    result = []
    row = []
    csv_characters = csv.split("")
    csv_characters.each_with_index do |c,i|
      case c
      when "," # カンマ
        if quote_flag
          token += c
        else
          row.push token
          token = ""
        end
        quote_count = 0
      when "\n" # 改行
        if quote_flag
          token += c
        else
          row.push token
          result.push row
          row = []
          token = ""
        end
        quote_count = 0
      when '"' # クオート
        if quote_count == 1 # 前もクオート
          quote_count = 0
          token += '"'
        elsif csv_characters[i+1] == '"' # 次がクオート
          if token == '' && !quote_flag
            quote_flag = true
          else
            quote_count += 1
            quote_count = 0 if quote_count == 2
          end
        else # クオートの開始と終了
          quote_flag = ! quote_flag
          quote_count = 0
        end
      else # 通常文字
        token += c
        quote_count = 0
      end
    end
    if token != "" # 末尾に改行がなかった場合
      row.push token
      token.push row
    end
    result
  end


end

csv0 = <<CSV
this,is,csv,parse,test
this,is,csv,parse,test
this,is,csv,parse,test
this,is,csv,parse,test
CSV

csv1 = <<CSV
this,is,csv,parse,test
"double","quote","is","also","ok"
you,can,also,insert,"new
line"
double,quote,test,"",""""
comma,test,",",",,","a,b,c"
,,,,
CSV

csv2 = "111,222,333,444,555"

p CSVParser.parse_by_regrex(csv2)
p CSVParser.parse_by_scan(csv2)
