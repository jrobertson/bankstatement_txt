#!/usr/bin/env ruby

# file: bankstatement_txt.rb

require 'csv'
require 'polyrex'


class BankStatementTxt
  
  attr_reader :px

  def initialize()
  end

  def import(filepath)

    new_import(filepath)
    
  end

  private

  def new_import(filepath)


    data = File.read filepath
    csv = CSV.new(data, :headers => true, :header_converters => :symbol, 
                  :converters => :all)
    a = csv.to_a.map(&:to_hash)

    a.reject!(&:empty?)
    a2 = a.group_by {|x| Date.parse(x[:date]).year }

    a3 = a2.inject({}) do |r, pair| 

      year, x = pair
      
      r.merge(year => x.group_by {|y| Date.parse(y[:date]).month})
    end

    px = Polyrex.new("statement[title,tags]/year[title]/month[title]/entry" + 
                     "[date, type, desc, credit, debit, balance, tags]")

    a3.each do |year, year_entries|

      px.create_year(title: year.to_s) do |create1|

        year_entries.each do |month, entries|

          create1.month(title: Date::ABBR_MONTHNAMES[month]) do |create2|

            entries.each do |x|

              v = x[:value]
              credit, debit = v > 0 ? [v, nil] : [nil, v.abs]
              create2.entry date: x[:date], type: x[:type], 
                            desc: x[:description], credit: credit, 
                            debit: debit, balance: x[:balance]

            end

          end

        end
      end
    end

    @px = px 

  end

end
