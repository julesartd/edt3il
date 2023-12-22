# frozen_string_literal: true

require 'open-uri'

module Api
  class ScheduleController < ApplicationController
    def index
      creneaux = {
        "1" => { start: "8h30", end: "10h" },
        "2" => { start: "10h30", end: "12h" },
        "3" => { start: "12h", end: "13h30" },
        "4" => { start: "13h30", end: "15h" },
        "5" => { start: "15h15", end: "16h45" },
        "6" => { start: "17h", end: "18h30" }
      }

      xml_url = 'https://eleves.groupe3il.fr/edt_eleves/B3%20Groupe%203%20DLW-FA.xml'
      xml_content = URI.open(xml_url).read
      xml_doc = Nokogiri::XML(xml_content)
      xml_hash = Hash.from_xml(xml_doc.to_s)
      json_content = xml_hash.to_json

      parsed_json = JSON.parse(json_content)

      parsed_json.each do |creneaux_array|
        creneaux_array.each do |creneau|
          creneau_value = creneau["Creneau"]
          pp creneau["Date"]
          pp creneau["CRENEAU"]
          creneau["CRENEAU"] = creneaux[creneau_value][:start] if creneaux.key?(creneau_value)

        end
      end

      grouped_schedule = {}

      parsed_json["DOCUMENT"]["GROUPE"]["PLAGES"]["SEMAINE"].each do |semaine|
        semaine["JOUR"].each do |jour|
          date = jour["Date"]
          grouped_schedule[date] ||= []

          jour["CRENEAU"].each do |creneau|
            # Remove the "Horaire" field from each "CRENEAU" entry
            creneau.delete("Horaire")

            grouped_schedule[date] << creneau
          end
        end
      end

      render json: grouped_schedule
    end
  end
end
