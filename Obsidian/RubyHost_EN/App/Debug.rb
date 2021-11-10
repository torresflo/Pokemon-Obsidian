#encoding: utf-8
#===
#>Dialog de debug
#---
# © 2014 - Nuri Yuri (塗 ゆり) Ecriture du script
#===
module App
  module DebugDialog
    module_function
    def run
      if @dlg and !@dlg.closed
        return DialogInterface::SetForgroundWindow(@dlg.hwnd)
      end
      if(!$game_data_pokemon)
        DialogInterface::MessageBox(0,"Veuillez charger un dossier de jeu.","Data introuvable",DialogInterface::Constants::MB_ICONERROR)
        return
      end
      
      DialogInterface::DialogBox(App::Dialogs[:debug],0) do |dialog|
=begin
Indentation retiré pour définir le dialog comme si c'était une classe
Dialog: AtkEditor
=end


  def dialog.on_command(hDlg,wmId,wmEvent,lParam)
    if(wmEvent==1) #CBN_SELCHANGE
      case wmId
      when App::Combo[1] #>Variables d'instance
        App::DebugDialog.set_combo(self.get_combo_pos(App::Combo[1]).to_i)
      end
      return
    elsif(wmEvent==0) #Press Button
      case wmId
      when App::Button[1] #>Se connecter au jeu
        self.enable_item(App::Button[1], false)
        App::DebugDialog.connect
      when App::Button[2] #>Récupérer la fenêtre
        App::DebugDialog.get_ghwnd
      when App::Button[3] #>Effacer
        self.set_item_text(App::Edit[1],"")
      when App::Button[4] #>Envoyer la commande
        App::DebugDialog.send_cmd
      end
    end
  
  end
  
  def dialog.on_close(hDlg)
    App::DebugDialog.instance_variable_set(:@dlg,nil)
    App::DebugDialog.disconnect
    GC.start
    return true
  end
  
  dialog.enable_item(App::Button[4], false)
  dialog.send_item_message(App::Edit[1], 0xC5, 4096, 0) #>Limite
  App::DebugDialog.instance_variable_set(:@dlg,dialog)
=begin
Fin de l'édition
=end
      end
    end
    
    def get_ghwnd
      return unless @client
      str = @dlg.get_item_text(App::Edit[1],4096)
      @dlg.set_item_text(App::Edit[1],"Kernel.get_handle")
      send_cmd
      @ghwnd = @dlg.get_item_text(App::Edit[2],60).to_i
      @dlg.set_item_text(App::Edit[1],str) if str
    end
    
    def disconnect
      @client.close if @client
      @client = nil
      @ghwnd = nil
    end
    
    def connect
      begin
        @client = TCPSocket.new("127.0.0.1",81)
        @dlg.enable_item(App::Button[4], true)
      rescue
        @client = nil
        DialogInterface::MessageBox(@dlg.hwnd,"Impossible de se connecter au jeu","Erreur de connexion",DialogInterface::Constants::MB_ICONERROR)
        @dlg.enable_item(App::Button[1], true)
      end
    end
    
    def send_cmd
      unless @client
        @dlg.enable_item(App::Button[4], false)
        @dlg.enable_item(App::Button[1], true)
      end
      str = @dlg.get_item_text(App::Edit[1],4096)
      begin
        @client.write(Marshal.dump(str))
        if(@ghwnd)
          DialogInterface::SetForgroundWindow(@ghwnd)
        end
        data = @client.recv(1024*1024)
      rescue
        DialogInterface::MessageBox(@dlg.hwnd,"Echec de l'envoie des données, la connexion est désormais fermée","Erreur de connexion",DialogInterface::Constants::MB_ICONERROR)
        @dlg.enable_item(App::Button[4], false)
        @dlg.enable_item(App::Button[1], true)
        @client.close rescue nil
        @client = nil
        return
      end
      begin
        arr = @arr = Marshal.load(data)
      rescue
        @dlg.set_item_text(App::Edit[2],"Marshal.load : Echec.\r\n#{data.inspect}")
        @dlg.set_item_text(App::Edit[3],"")
        @dlg.set_item_text(App::Edit[4],"")
        @dlg.set_combo_list(App::Combo[1],[])
        @arr = ["","",{}]
        @iv_arr = []
        return
      end
      @dlg.set_item_text(App::Edit[2],arr[1].to_s)
      @dlg.set_item_text(App::Edit[3],arr[0].to_s)
      
      iv_arr = []
      arr[2].each_key do |key|
        iv_arr << key.to_s
      end
      @dlg.set_combo_list(App::Combo[1],iv_arr)
      @iv_arr = iv_arr
      @dlg.set_combo_pos(App::Combo[1],0, true)
      @dlg.set_item_text(App::Edit[4],arr[2][iv_arr[0]].to_s)
    end
    
    def set_combo(pos)
      if(val = @iv_arr[pos])
        @dlg.set_item_text(App::Edit[4],@arr[2][val].to_s)
      end
    end
  end
end