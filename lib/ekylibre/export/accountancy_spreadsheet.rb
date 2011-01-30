module Ekylibre

  module Export

    class AccountancySpreadsheet


      @@format = [
                  [3,  "j.code[0..1]"], # Code journal
                  [8,  "je.number[0..1]+je.number[-6..-1]"], # Numéro de pièce
                  [8,  "fdt(je.printed_on)"], # Date.pièce
                  [30, "jel.name"], # Libllé de l'écriture
                  [3,  "je.currency.code"], # Devise
                  [10, "a.number"], # N° compte
                  [10, ""], # Compte centralisateur
                  [30, "a.name"], # Libellé du compte
                  [30, "jel.name"], # Libellé du mouvement
                  [13, "100*jel.debit", "r"], # Débit centimes
                  [13, "100*jel.credit", "r"], # Crédit
                  [11, ""], # Qté 1
                  [11, ""], # Qté 2
                  [8,  "jel.position", "r"], # Numéro
                  [4,  ""], # Code TVA
                  [3,  "jel.letter"], # Lettrage
                  [8,  "jel.bank_statement ? fdt(jel.bank_statement.stopped_on) : nil"], # Date de pointage
                  [10, ""], # Activité
                  [2,  ""], # Découpe de l'act
                  [40, ""], # Libellé de l'act
                  [4,  ""], # Code TVA associé au compte TVA
                  [8,  ""], # Date échéance
                  [10, ""], # Compte de contepartie
                  [8,  ""]  # Date sur mouvement
                 ]


      def self.generate(company, started_on, stopped_on)
        carre = ""
        code = ""
        code += "for j in company.journals\n"
        code += "  for je in j.entries.find(:all, :conditions=>['printed_on BETWEEN ? AND ?', started_on, stopped_on], :order=>'journal_id, number')\n"
        code += "    for jel in je.lines.find(:all, :order=>:position)\n"
        code += "      a = jel.account\n"
        code += "      carre += "
        for column in @@format
          if column[1].blank?
            code += "'"+(' '*column[0])+"'+"
          else
            code += "(#{column[1]}).to_s.#{'l'||column[2]||'l'}just(#{column[0]})[0..#{column[0]-1}]+"
          end
        end
        code += '"\n"'+"\n"
        code += "    end\n"
        code += "  end\n"
        code += "end\n"
        eval(code)
        return carre
      end

      private

      def self.fdt(date)
        date.day.to_s.rjust(2, "0")+date.month.to_s.rjust(2, "0")+date.year.to_s.rjust(4, "0")
      end
      

    end
    
  end


end
