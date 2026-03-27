import Foundation

enum L10n {
    private static let strings: [String: [String: String]] = [
        "en": [
            "device_connected": "Device connected",
            "no_device_connected": "No device connected",
            "audio_input_permission_format": "Audio Input Permission: %@",
            "permission_granted": "Granted",
            "permission_denied": "Denied",
            "permission_requesting": "Requesting",
            "permission_restricted": "Restricted",
            "permission_unknown": "Unknown",
            "show_expert_panel": "Show Expert Panel",
            "hide_expert_panel": "Hide Expert Panel",
            "broadcasts": "Broadcasts",
            "scanning": "Scanning",
            "scanning_for_broadcasts": "Scanning for broadcasts...",
            "connect_receiver_to_begin_scanning": "Connect the receiver to begin scanning.",
            "support": "Support",
            "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN Required",
            "enter_pin_for_broadcast_format": "Enter the PIN for %@.",
            "this_broadcast": "this broadcast",
            "pin_code": "PIN Code",
            "cancel": "Cancel",
            "submit": "Submit",
            "idle": "Idle",
            "starting": "Starting",
            "on_device_format": "On %@",
            "audio_failed_format": "Audio failed: %@",
            "receiver_idle": "Idle",
            "receiver_scanning": "Scanning",
            "receiver_syncing": "Syncing",
            "receiver_streaming": "Streaming",
            "receiver_pin_required": "PIN Required",
            "receiver_unknown": "Unknown",
            "live": "LIVE",
            "sync": "SYNC",
            "enc": "ENC",
            "expert_panel": "Expert Panel",
            "receiver_state": "Receiver State",
            "broadcast": "Broadcast",
            "source": "Source",
            "pa_sync": "PA Sync",
            "enc_label": "Enc",
            "bis": "BIS",
            "connected_device": "Connected Device",
            "advanced_actions": "Receiver Commands",
            "query_sync": "Query Sync",
            "start_scan": "Start Scan",
            "stop_scan": "Stop Scan",
            "sync_selected": "Sync Selected",
            "stop_sync": "Stop Sync",
            "command": "Command",
            "send": "Send",
            "session_log": "Session Log",
            "clear": "Clear",
            "serial": "Serial",
            "baud_rate_format": "Baud Rate: %d",
            "append_carriage_return": "Append carriage return",
            "append_newline": "Append newline",
            "next": "Next",
            "next_description": "This app is set up for CDC serial control and Auracast response parsing first. We can layer higher-level receiver workflows on top once the device link is stable."
        ],
        "zh-Hans": [
            "device_connected": "设备已连接", "no_device_connected": "未连接设备", "audio_input_permission_format": "音频输入权限：%@",
            "permission_granted": "已允许", "permission_denied": "已拒绝", "permission_requesting": "请求中", "permission_restricted": "受限制", "permission_unknown": "未知",
            "show_expert_panel": "显示专家面板", "hide_expert_panel": "隐藏专家面板", "broadcasts": "广播", "scanning": "扫描中",
            "scanning_for_broadcasts": "正在扫描广播...", "connect_receiver_to_begin_scanning": "连接接收器以开始扫描。", "support": "支持", "copyright": "版权所有 © 2026 Flairmesh Technologies",
            "pin_required": "需要 PIN 码", "enter_pin_for_broadcast_format": "请输入 %@ 的 PIN 码。", "this_broadcast": "此广播", "pin_code": "PIN 码", "cancel": "取消", "submit": "提交",
            "idle": "空闲", "starting": "启动中", "on_device_format": "在 %@ 上", "audio_failed_format": "音频失败：%@", "receiver_idle": "空闲", "receiver_scanning": "扫描中", "receiver_syncing": "同步中", "receiver_streaming": "播放中", "receiver_pin_required": "需要 PIN 码", "receiver_unknown": "未知",
            "live": "直播", "sync": "同步", "enc": "加密", "expert_panel": "专家面板", "receiver_state": "接收器状态", "broadcast": "广播", "source": "源", "pa_sync": "PA 同步", "enc_label": "加密", "bis": "BIS", "connected_device": "已连接设备", "advanced_actions": "接收器命令", "query_sync": "查询同步", "start_scan": "开始扫描", "stop_scan": "停止扫描", "sync_selected": "同步所选", "stop_sync": "停止同步", "command": "命令", "send": "发送", "session_log": "会话日志", "clear": "清除", "serial": "串口", "baud_rate_format": "波特率：%d", "append_carriage_return": "附加回车", "append_newline": "附加换行", "next": "后续", "next_description": "此应用目前首先支持 CDC 串口控制和 Auracast 响应解析。待设备链路稳定后，我们可以在其上添加更高级的接收器工作流。"
        ],
        "zh-Hant": [
            "device_connected": "裝置已連接", "no_device_connected": "未連接裝置", "audio_input_permission_format": "音訊輸入權限：%@",
            "permission_granted": "已允許", "permission_denied": "已拒絕", "permission_requesting": "請求中", "permission_restricted": "受限制", "permission_unknown": "未知",
            "show_expert_panel": "顯示專家面板", "hide_expert_panel": "隱藏專家面板", "broadcasts": "廣播", "scanning": "掃描中",
            "scanning_for_broadcasts": "正在掃描廣播...", "connect_receiver_to_begin_scanning": "連接接收器以開始掃描。", "support": "支援", "copyright": "版權所有 © 2026 Flairmesh Technologies",
            "pin_required": "需要 PIN 碼", "enter_pin_for_broadcast_format": "請輸入 %@ 的 PIN 碼。", "this_broadcast": "此廣播", "pin_code": "PIN 碼", "cancel": "取消", "submit": "提交",
            "idle": "閒置", "starting": "啟動中", "on_device_format": "在 %@ 上", "audio_failed_format": "音訊失敗：%@", "receiver_idle": "閒置", "receiver_scanning": "掃描中", "receiver_syncing": "同步中", "receiver_streaming": "播放中", "receiver_pin_required": "需要 PIN 碼", "receiver_unknown": "未知",
            "live": "直播", "sync": "同步", "enc": "加密", "expert_panel": "專家面板", "receiver_state": "接收器狀態", "broadcast": "廣播", "source": "來源", "pa_sync": "PA 同步", "enc_label": "加密", "bis": "BIS", "connected_device": "已連接裝置", "advanced_actions": "接收器命令", "query_sync": "查詢同步", "start_scan": "開始掃描", "stop_scan": "停止掃描", "sync_selected": "同步所選", "stop_sync": "停止同步", "command": "命令", "send": "傳送", "session_log": "工作階段日誌", "clear": "清除", "serial": "串列", "baud_rate_format": "鮑率：%d", "append_carriage_return": "附加回車", "append_newline": "附加換行", "next": "後續", "next_description": "此應用目前首先支援 CDC 串列控制與 Auracast 回應解析。待裝置連線穩定後，我們可在其上加入更高階的接收器流程。"
        ],
        "ja": [
            "device_connected": "デバイス接続済み", "no_device_connected": "デバイス未接続", "audio_input_permission_format": "音声入力の許可：%@",
            "permission_granted": "許可済み", "permission_denied": "拒否", "permission_requesting": "要求中", "permission_restricted": "制限あり", "permission_unknown": "不明",
            "show_expert_panel": "詳細パネルを表示", "hide_expert_panel": "詳細パネルを隠す", "broadcasts": "ブロードキャスト", "scanning": "スキャン中",
            "scanning_for_broadcasts": "ブロードキャストをスキャン中...", "connect_receiver_to_begin_scanning": "スキャンを開始するには受信機を接続してください。", "support": "サポート", "copyright": "著作権 © 2026 Flairmesh Technologies",
            "pin_required": "PIN が必要です", "enter_pin_for_broadcast_format": "%@ の PIN を入力してください。", "this_broadcast": "このブロードキャスト", "pin_code": "PIN コード", "cancel": "キャンセル", "submit": "送信",
            "idle": "待機中", "starting": "開始中", "on_device_format": "%@ で再生中", "audio_failed_format": "音声エラー: %@", "receiver_idle": "待機中", "receiver_scanning": "スキャン中", "receiver_syncing": "同期中", "receiver_streaming": "再生中", "receiver_pin_required": "PIN が必要です", "receiver_unknown": "不明",
            "live": "LIVE", "sync": "同期", "enc": "暗号化", "expert_panel": "詳細パネル", "receiver_state": "受信機の状態", "broadcast": "ブロードキャスト", "source": "ソース", "pa_sync": "PA 同期", "enc_label": "暗号", "bis": "BIS", "connected_device": "接続中のデバイス", "advanced_actions": "受信機コマンド", "query_sync": "同期を確認", "start_scan": "スキャン開始", "stop_scan": "スキャン停止", "sync_selected": "選択を同期", "stop_sync": "同期停止", "command": "コマンド", "send": "送信", "session_log": "セッションログ", "clear": "クリア", "serial": "シリアル", "baud_rate_format": "ボーレート: %d", "append_carriage_return": "復帰を追加", "append_newline": "改行を追加", "next": "次へ", "next_description": "このアプリはまず CDC シリアル制御と Auracast 応答解析に対応しています。デバイス接続が安定したら、より高レベルの受信ワークフローを追加できます。"
        ],
        "ko": [
            "device_connected": "장치 연결됨", "no_device_connected": "장치가 연결되지 않음", "audio_input_permission_format": "오디오 입력 권한: %@",
            "permission_granted": "허용됨", "permission_denied": "거부됨", "permission_requesting": "요청 중", "permission_restricted": "제한됨", "permission_unknown": "알 수 없음",
            "show_expert_panel": "전문가 패널 표시", "hide_expert_panel": "전문가 패널 숨기기", "broadcasts": "방송", "scanning": "검색 중",
            "scanning_for_broadcasts": "방송 검색 중...", "connect_receiver_to_begin_scanning": "검색을 시작하려면 수신기를 연결하세요.", "support": "지원", "copyright": "저작권 © 2026 Flairmesh Technologies",
            "pin_required": "PIN 필요", "enter_pin_for_broadcast_format": "%@의 PIN을 입력하세요.", "this_broadcast": "이 방송", "pin_code": "PIN 코드", "cancel": "취소", "submit": "제출",
            "idle": "대기", "starting": "시작 중", "on_device_format": "%@에서 재생 중", "audio_failed_format": "오디오 실패: %@", "receiver_idle": "대기", "receiver_scanning": "검색 중", "receiver_syncing": "동기화 중", "receiver_streaming": "재생 중", "receiver_pin_required": "PIN 필요", "receiver_unknown": "알 수 없음",
            "live": "LIVE", "sync": "동기화", "enc": "암호화", "expert_panel": "전문가 패널", "receiver_state": "수신기 상태", "broadcast": "방송", "source": "소스", "pa_sync": "PA 동기화", "enc_label": "암호", "bis": "BIS", "connected_device": "연결된 장치", "advanced_actions": "수신기 명령", "query_sync": "동기화 조회", "start_scan": "검색 시작", "stop_scan": "검색 중지", "sync_selected": "선택 항목 동기화", "stop_sync": "동기화 중지", "command": "명령", "send": "전송", "session_log": "세션 로그", "clear": "지우기", "serial": "시리얼", "baud_rate_format": "전송 속도: %d", "append_carriage_return": "캐리지 리턴 추가", "append_newline": "줄 바꿈 추가", "next": "다음", "next_description": "이 앱은 우선 CDC 시리얼 제어와 Auracast 응답 파싱을 지원합니다. 장치 연결이 안정되면 그 위에 더 높은 수준의 수신기 워크플로를 추가할 수 있습니다."
        ],
        "fr": [
            "device_connected": "Appareil connecté", "no_device_connected": "Aucun appareil connecté", "audio_input_permission_format": "Autorisation d'entrée audio : %@",
            "permission_granted": "Accordée", "permission_denied": "Refusée", "permission_requesting": "En cours", "permission_restricted": "Restreinte", "permission_unknown": "Inconnue",
            "show_expert_panel": "Afficher le panneau expert", "hide_expert_panel": "Masquer le panneau expert", "broadcasts": "Diffusions", "scanning": "Recherche en cours",
            "scanning_for_broadcasts": "Recherche de diffusions...", "connect_receiver_to_begin_scanning": "Connectez le récepteur pour commencer la recherche.", "support": "Support", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN requis", "enter_pin_for_broadcast_format": "Saisissez le PIN pour %@.", "this_broadcast": "cette diffusion", "pin_code": "Code PIN", "cancel": "Annuler", "submit": "Valider",
            "idle": "Inactif", "starting": "Démarrage", "on_device_format": "Sur %@", "audio_failed_format": "Échec audio : %@", "receiver_idle": "Inactif", "receiver_scanning": "Recherche", "receiver_syncing": "Synchronisation", "receiver_streaming": "Lecture", "receiver_pin_required": "PIN requis", "receiver_unknown": "Inconnu",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Panneau expert", "receiver_state": "État du récepteur", "broadcast": "Diffusion", "source": "Source", "pa_sync": "Synchro PA", "enc_label": "Chiff.", "bis": "BIS", "connected_device": "Appareil connecté", "advanced_actions": "Commandes du récepteur", "query_sync": "Interroger la synchro", "start_scan": "Démarrer la recherche", "stop_scan": "Arrêter la recherche", "sync_selected": "Synchroniser la sélection", "stop_sync": "Arrêter la synchro", "command": "Commande", "send": "Envoyer", "session_log": "Journal de session", "clear": "Effacer", "serial": "Série", "baud_rate_format": "Débit : %d", "append_carriage_return": "Ajouter un retour chariot", "append_newline": "Ajouter une nouvelle ligne", "next": "Suite", "next_description": "Cette app est d'abord configurée pour le contrôle CDC série et l'analyse des réponses Auracast. Nous pourrons ajouter des flux de travail de récepteur plus avancés une fois la liaison stable."
        ],
        "de": [
            "device_connected": "Gerät verbunden", "no_device_connected": "Kein Gerät verbunden", "audio_input_permission_format": "Audioeingabeberechtigung: %@",
            "permission_granted": "Erteilt", "permission_denied": "Verweigert", "permission_requesting": "Angefordert", "permission_restricted": "Eingeschränkt", "permission_unknown": "Unbekannt",
            "show_expert_panel": "Expertenbereich anzeigen", "hide_expert_panel": "Expertenbereich ausblenden", "broadcasts": "Broadcasts", "scanning": "Suche läuft",
            "scanning_for_broadcasts": "Suche nach Broadcasts...", "connect_receiver_to_begin_scanning": "Empfänger verbinden, um die Suche zu starten.", "support": "Support", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN erforderlich", "enter_pin_for_broadcast_format": "PIN für %@ eingeben.", "this_broadcast": "diesen Broadcast", "pin_code": "PIN-Code", "cancel": "Abbrechen", "submit": "Senden",
            "idle": "Leerlauf", "starting": "Startet", "on_device_format": "Auf %@", "audio_failed_format": "Audiofehler: %@", "receiver_idle": "Leerlauf", "receiver_scanning": "Suche läuft", "receiver_syncing": "Synchronisierung", "receiver_streaming": "Wiedergabe", "receiver_pin_required": "PIN erforderlich", "receiver_unknown": "Unbekannt",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Expertenbereich", "receiver_state": "Empfängerstatus", "broadcast": "Broadcast", "source": "Quelle", "pa_sync": "PA-Sync", "enc_label": "Verschl.", "bis": "BIS", "connected_device": "Verbundenes Gerät", "advanced_actions": "Empfängerbefehle", "query_sync": "Sync abfragen", "start_scan": "Suche starten", "stop_scan": "Suche stoppen", "sync_selected": "Auswahl synchronisieren", "stop_sync": "Sync stoppen", "command": "Befehl", "send": "Senden", "session_log": "Sitzungsprotokoll", "clear": "Löschen", "serial": "Seriell", "baud_rate_format": "Baudrate: %d", "append_carriage_return": "Wagenrücklauf anhängen", "append_newline": "Zeilenumbruch anhängen", "next": "Weiter", "next_description": "Diese App ist zunächst für CDC-Seriellsteuerung und Auracast-Antwortanalyse eingerichtet. Darauf können wir später höhere Empfänger-Workflows aufbauen, sobald die Geräteverbindung stabil ist."
        ],
        "es": [
            "device_connected": "Dispositivo conectado", "no_device_connected": "Ningún dispositivo conectado", "audio_input_permission_format": "Permiso de entrada de audio: %@",
            "permission_granted": "Concedido", "permission_denied": "Denegado", "permission_requesting": "Solicitando", "permission_restricted": "Restringido", "permission_unknown": "Desconocido",
            "show_expert_panel": "Mostrar panel experto", "hide_expert_panel": "Ocultar panel experto", "broadcasts": "Emisiones", "scanning": "Buscando",
            "scanning_for_broadcasts": "Buscando emisiones...", "connect_receiver_to_begin_scanning": "Conecta el receptor para comenzar a buscar.", "support": "Soporte", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN requerido", "enter_pin_for_broadcast_format": "Introduce el PIN de %@.", "this_broadcast": "esta emisión", "pin_code": "Código PIN", "cancel": "Cancelar", "submit": "Enviar",
            "idle": "Inactivo", "starting": "Iniciando", "on_device_format": "En %@", "audio_failed_format": "Error de audio: %@", "receiver_idle": "Inactivo", "receiver_scanning": "Buscando", "receiver_syncing": "Sincronizando", "receiver_streaming": "Reproduciendo", "receiver_pin_required": "PIN requerido", "receiver_unknown": "Desconocido",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Panel experto", "receiver_state": "Estado del receptor", "broadcast": "Emisión", "source": "Fuente", "pa_sync": "Sincronía PA", "enc_label": "Cif.", "bis": "BIS", "connected_device": "Dispositivo conectado", "advanced_actions": "Comandos del receptor", "query_sync": "Consultar sincronía", "start_scan": "Iniciar búsqueda", "stop_scan": "Detener búsqueda", "sync_selected": "Sincronizar selección", "stop_sync": "Detener sincronía", "command": "Comando", "send": "Enviar", "session_log": "Registro de sesión", "clear": "Limpiar", "serial": "Serie", "baud_rate_format": "Velocidad en baudios: %d", "append_carriage_return": "Añadir retorno de carro", "append_newline": "Añadir nueva línea", "next": "Siguiente", "next_description": "Esta app está configurada primero para control serie CDC y análisis de respuestas Auracast. Podemos añadir flujos de trabajo de receptor de nivel superior cuando el enlace del dispositivo sea estable."
        ],
        "pt-BR": [
            "device_connected": "Dispositivo conectado", "no_device_connected": "Nenhum dispositivo conectado", "audio_input_permission_format": "Permissão de entrada de áudio: %@",
            "permission_granted": "Concedida", "permission_denied": "Negada", "permission_requesting": "Solicitando", "permission_restricted": "Restrita", "permission_unknown": "Desconhecida",
            "show_expert_panel": "Mostrar painel avançado", "hide_expert_panel": "Ocultar painel avançado", "broadcasts": "Transmissões", "scanning": "Procurando",
            "scanning_for_broadcasts": "Procurando transmissões...", "connect_receiver_to_begin_scanning": "Conecte o receptor para iniciar a busca.", "support": "Suporte", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN necessário", "enter_pin_for_broadcast_format": "Digite o PIN de %@.", "this_broadcast": "esta transmissão", "pin_code": "Código PIN", "cancel": "Cancelar", "submit": "Enviar",
            "idle": "Inativo", "starting": "Iniciando", "on_device_format": "Em %@", "audio_failed_format": "Falha de áudio: %@", "receiver_idle": "Inativo", "receiver_scanning": "Procurando", "receiver_syncing": "Sincronizando", "receiver_streaming": "Transmitindo", "receiver_pin_required": "PIN necessário", "receiver_unknown": "Desconhecido",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Painel avançado", "receiver_state": "Estado do receptor", "broadcast": "Transmissão", "source": "Fonte", "pa_sync": "Sincronia PA", "enc_label": "Cript.", "bis": "BIS", "connected_device": "Dispositivo conectado", "advanced_actions": "Comandos do receptor", "query_sync": "Consultar sincronização", "start_scan": "Iniciar busca", "stop_scan": "Parar busca", "sync_selected": "Sincronizar selecionado", "stop_sync": "Parar sincronização", "command": "Comando", "send": "Enviar", "session_log": "Log da sessão", "clear": "Limpar", "serial": "Serial", "baud_rate_format": "Taxa de baud: %d", "append_carriage_return": "Adicionar retorno de carro", "append_newline": "Adicionar nova linha", "next": "Próximo", "next_description": "Este app está configurado primeiro para controle serial CDC e análise de respostas Auracast. Podemos adicionar fluxos de receptor de nível superior quando o link do dispositivo estiver estável."
        ],
        "it": [
            "device_connected": "Dispositivo connesso", "no_device_connected": "Nessun dispositivo connesso", "audio_input_permission_format": "Autorizzazione ingresso audio: %@",
            "permission_granted": "Concessa", "permission_denied": "Negata", "permission_requesting": "Richiesta in corso", "permission_restricted": "Limitata", "permission_unknown": "Sconosciuta",
            "show_expert_panel": "Mostra pannello esperto", "hide_expert_panel": "Nascondi pannello esperto", "broadcasts": "Trasmissioni", "scanning": "Scansione in corso",
            "scanning_for_broadcasts": "Ricerca delle trasmissioni...", "connect_receiver_to_begin_scanning": "Collega il ricevitore per iniziare la scansione.", "support": "Supporto", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN richiesto", "enter_pin_for_broadcast_format": "Inserisci il PIN per %@.", "this_broadcast": "questa trasmissione", "pin_code": "Codice PIN", "cancel": "Annulla", "submit": "Invia",
            "idle": "Inattivo", "starting": "Avvio", "on_device_format": "Su %@", "audio_failed_format": "Errore audio: %@", "receiver_idle": "Inattivo", "receiver_scanning": "Scansione", "receiver_syncing": "Sincronizzazione", "receiver_streaming": "In riproduzione", "receiver_pin_required": "PIN richiesto", "receiver_unknown": "Sconosciuto",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Pannello esperto", "receiver_state": "Stato ricevitore", "broadcast": "Trasmissione", "source": "Sorgente", "pa_sync": "PA Sync", "enc_label": "Cifr.", "bis": "BIS", "connected_device": "Dispositivo connesso", "advanced_actions": "Comandi del ricevitore", "query_sync": "Verifica sincronizzazione", "start_scan": "Avvia scansione", "stop_scan": "Ferma scansione", "sync_selected": "Sincronizza selezione", "stop_sync": "Ferma sincronizzazione", "command": "Comando", "send": "Invia", "session_log": "Log sessione", "clear": "Cancella", "serial": "Seriale", "baud_rate_format": "Baud rate: %d", "append_carriage_return": "Aggiungi ritorno a capo", "append_newline": "Aggiungi nuova riga", "next": "Avanti", "next_description": "Questa app è configurata prima di tutto per il controllo seriale CDC e l'analisi delle risposte Auracast. Possiamo aggiungere flussi di ricezione più avanzati quando il collegamento del dispositivo sarà stabile."
        ],
        "nl": [
            "device_connected": "Apparaat verbonden", "no_device_connected": "Geen apparaat verbonden", "audio_input_permission_format": "Toestemming audio-invoer: %@",
            "permission_granted": "Toegestaan", "permission_denied": "Geweigerd", "permission_requesting": "Aanvragen", "permission_restricted": "Beperkt", "permission_unknown": "Onbekend",
            "show_expert_panel": "Expertpaneel tonen", "hide_expert_panel": "Expertpaneel verbergen", "broadcasts": "Uitzendingen", "scanning": "Scannen",
            "scanning_for_broadcasts": "Zoeken naar uitzendingen...", "connect_receiver_to_begin_scanning": "Sluit de ontvanger aan om te beginnen met scannen.", "support": "Ondersteuning", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN vereist", "enter_pin_for_broadcast_format": "Voer de PIN in voor %@.", "this_broadcast": "deze uitzending", "pin_code": "PIN-code", "cancel": "Annuleren", "submit": "Verzenden",
            "idle": "Inactief", "starting": "Starten", "on_device_format": "Op %@", "audio_failed_format": "Audiofout: %@", "receiver_idle": "Inactief", "receiver_scanning": "Scannen", "receiver_syncing": "Synchroniseren", "receiver_streaming": "Afspelen", "receiver_pin_required": "PIN vereist", "receiver_unknown": "Onbekend",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Expertpaneel", "receiver_state": "Ontvangerstatus", "broadcast": "Uitzending", "source": "Bron", "pa_sync": "PA-sync", "enc_label": "Versl.", "bis": "BIS", "connected_device": "Verbonden apparaat", "advanced_actions": "Ontvangeropdrachten", "query_sync": "Synchronisatie opvragen", "start_scan": "Scan starten", "stop_scan": "Scan stoppen", "sync_selected": "Selectie synchroniseren", "stop_sync": "Synchronisatie stoppen", "command": "Opdracht", "send": "Verzenden", "session_log": "Sessielogboek", "clear": "Wissen", "serial": "Serieel", "baud_rate_format": "Baudsnelheid: %d", "append_carriage_return": "Carriage return toevoegen", "append_newline": "Nieuwe regel toevoegen", "next": "Volgende", "next_description": "Deze app is eerst ingericht voor CDC-seriële besturing en Auracast-responsanalyse. We kunnen later hogere ontvangerworkflows toevoegen zodra de apparaatkoppeling stabiel is."
        ],
        "ru": [
            "device_connected": "Устройство подключено", "no_device_connected": "Устройство не подключено", "audio_input_permission_format": "Разрешение на аудиовход: %@",
            "permission_granted": "Разрешено", "permission_denied": "Запрещено", "permission_requesting": "Запрос", "permission_restricted": "Ограничено", "permission_unknown": "Неизвестно",
            "show_expert_panel": "Показать экспертную панель", "hide_expert_panel": "Скрыть экспертную панель", "broadcasts": "Трансляции", "scanning": "Сканирование",
            "scanning_for_broadcasts": "Поиск трансляций...", "connect_receiver_to_begin_scanning": "Подключите приёмник, чтобы начать поиск.", "support": "Поддержка", "copyright": "Авторские права © 2026 Flairmesh Technologies",
            "pin_required": "Требуется PIN", "enter_pin_for_broadcast_format": "Введите PIN для %@.", "this_broadcast": "этой трансляции", "pin_code": "PIN-код", "cancel": "Отмена", "submit": "Отправить",
            "idle": "Ожидание", "starting": "Запуск", "on_device_format": "На %@", "audio_failed_format": "Ошибка аудио: %@", "receiver_idle": "Ожидание", "receiver_scanning": "Сканирование", "receiver_syncing": "Синхронизация", "receiver_streaming": "Воспроизведение", "receiver_pin_required": "Требуется PIN", "receiver_unknown": "Неизвестно",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Экспертная панель", "receiver_state": "Состояние приёмника", "broadcast": "Трансляция", "source": "Источник", "pa_sync": "Синхр. PA", "enc_label": "Шифр.", "bis": "BIS", "connected_device": "Подключённое устройство", "advanced_actions": "Команды приёмника", "query_sync": "Запросить синхронизацию", "start_scan": "Начать поиск", "stop_scan": "Остановить поиск", "sync_selected": "Синхронизировать выбранное", "stop_sync": "Остановить синхронизацию", "command": "Команда", "send": "Отправить", "session_log": "Журнал сеанса", "clear": "Очистить", "serial": "Последовательный", "baud_rate_format": "Скорость: %d", "append_carriage_return": "Добавлять CR", "append_newline": "Добавлять новую строку", "next": "Далее", "next_description": "Это приложение сначала настроено для CDC-последовательного управления и разбора ответов Auracast. Мы сможем добавить более высокоуровневые сценарии приёмника, когда связь с устройством станет стабильной."
        ],
        "hi": [
            "device_connected": "डिवाइस जुड़ा हुआ है", "no_device_connected": "कोई डिवाइस जुड़ी नहीं है", "audio_input_permission_format": "ऑडियो इनपुट अनुमति: %@",
            "permission_granted": "अनुमत", "permission_denied": "अस्वीकृत", "permission_requesting": "अनुरोध किया जा रहा है", "permission_restricted": "प्रतिबंधित", "permission_unknown": "अज्ञात",
            "show_expert_panel": "विशेषज्ञ पैनल दिखाएँ", "hide_expert_panel": "विशेषज्ञ पैनल छिपाएँ", "broadcasts": "प्रसारण", "scanning": "स्कैन किया जा रहा है",
            "scanning_for_broadcasts": "प्रसारण खोजे जा रहे हैं...", "connect_receiver_to_begin_scanning": "स्कैन शुरू करने के लिए रिसीवर जोड़ें।", "support": "सहायता", "copyright": "कॉपीराइट © 2026 Flairmesh Technologies",
            "pin_required": "PIN आवश्यक है", "enter_pin_for_broadcast_format": "%@ के लिए PIN दर्ज करें।", "this_broadcast": "इस प्रसारण", "pin_code": "PIN कोड", "cancel": "रद्द करें", "submit": "जमा करें",
            "idle": "निष्क्रिय", "starting": "शुरू हो रहा है", "on_device_format": "%@ पर", "audio_failed_format": "ऑडियो विफल: %@", "receiver_idle": "निष्क्रिय", "receiver_scanning": "स्कैन हो रहा है", "receiver_syncing": "सिंक हो रहा है", "receiver_streaming": "स्ट्रीमिंग", "receiver_pin_required": "PIN आवश्यक है", "receiver_unknown": "अज्ञात",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "विशेषज्ञ पैनल", "receiver_state": "रिसीवर स्थिति", "broadcast": "प्रसारण", "source": "स्रोत", "pa_sync": "PA सिंक", "enc_label": "एन्क.", "bis": "BIS", "connected_device": "जुड़ा हुआ डिवाइस", "advanced_actions": "रिसीवर कमांड", "query_sync": "सिंक जाँचें", "start_scan": "स्कैन शुरू करें", "stop_scan": "स्कैन रोकें", "sync_selected": "चयनित को सिंक करें", "stop_sync": "सिंक रोकें", "command": "कमांड", "send": "भेजें", "session_log": "सत्र लॉग", "clear": "साफ़ करें", "serial": "सीरियल", "baud_rate_format": "बॉड रेट: %d", "append_carriage_return": "कैरेज रिटर्न जोड़ें", "append_newline": "नई पंक्ति जोड़ें", "next": "आगे", "next_description": "यह ऐप पहले CDC सीरियल नियंत्रण और Auracast प्रतिक्रिया पार्सिंग के लिए तैयार की गई है। डिवाइस लिंक स्थिर होने पर हम इसके ऊपर उच्च-स्तरीय रिसीवर वर्कफ़्लो जोड़ सकते हैं।"
        ],
        "pl": [
            "device_connected": "Urządzenie podłączone", "no_device_connected": "Brak podłączonego urządzenia", "audio_input_permission_format": "Uprawnienie wejścia audio: %@",
            "permission_granted": "Przyznano", "permission_denied": "Odmówiono", "permission_requesting": "Żądanie", "permission_restricted": "Ograniczone", "permission_unknown": "Nieznane",
            "show_expert_panel": "Pokaż panel eksperta", "hide_expert_panel": "Ukryj panel eksperta", "broadcasts": "Transmisje", "scanning": "Skanowanie",
            "scanning_for_broadcasts": "Skanowanie transmisji...", "connect_receiver_to_begin_scanning": "Podłącz odbiornik, aby rozpocząć skanowanie.", "support": "Pomoc", "copyright": "Prawa autorskie © 2026 Flairmesh Technologies",
            "pin_required": "Wymagany PIN", "enter_pin_for_broadcast_format": "Wprowadź PIN dla %@.", "this_broadcast": "tej transmisji", "pin_code": "Kod PIN", "cancel": "Anuluj", "submit": "Wyślij",
            "idle": "Bezczynny", "starting": "Uruchamianie", "on_device_format": "Na %@", "audio_failed_format": "Błąd audio: %@", "receiver_idle": "Bezczynny", "receiver_scanning": "Skanowanie", "receiver_syncing": "Synchronizacja", "receiver_streaming": "Odtwarzanie", "receiver_pin_required": "Wymagany PIN", "receiver_unknown": "Nieznany",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Panel eksperta", "receiver_state": "Stan odbiornika", "broadcast": "Transmisja", "source": "Źródło", "pa_sync": "Synchronizacja PA", "enc_label": "Szyfr.", "bis": "BIS", "connected_device": "Podłączone urządzenie", "advanced_actions": "Polecenia odbiornika", "query_sync": "Sprawdź synchronizację", "start_scan": "Rozpocznij skanowanie", "stop_scan": "Zatrzymaj skanowanie", "sync_selected": "Synchronizuj wybrane", "stop_sync": "Zatrzymaj synchronizację", "command": "Polecenie", "send": "Wyślij", "session_log": "Dziennik sesji", "clear": "Wyczyść", "serial": "Szeregowy", "baud_rate_format": "Prędkość: %d", "append_carriage_return": "Dodaj CR", "append_newline": "Dodaj nową linię", "next": "Dalej", "next_description": "Ta aplikacja jest najpierw przygotowana do sterowania CDC przez port szeregowy i analizy odpowiedzi Auracast. Gdy połączenie z urządzeniem będzie stabilne, możemy dodać bardziej zaawansowane przepływy odbiornika."
        ],
        "sk": [
            "device_connected": "Zariadenie pripojené", "no_device_connected": "Žiadne zariadenie nie je pripojené", "audio_input_permission_format": "Povolenie vstupu zvuku: %@",
            "permission_granted": "Povolené", "permission_denied": "Zamietnuté", "permission_requesting": "Vyžaduje sa", "permission_restricted": "Obmedzené", "permission_unknown": "Neznáme",
            "show_expert_panel": "Zobraziť expertný panel", "hide_expert_panel": "Skryť expertný panel", "broadcasts": "Vysielania", "scanning": "Skenovanie",
            "scanning_for_broadcasts": "Vyhľadávanie vysielaní...", "connect_receiver_to_begin_scanning": "Pripojte prijímač a začnite skenovanie.", "support": "Podpora", "copyright": "Autorské práva © 2026 Flairmesh Technologies",
            "pin_required": "Vyžaduje sa PIN", "enter_pin_for_broadcast_format": "Zadajte PIN pre %@.", "this_broadcast": "toto vysielanie", "pin_code": "PIN kód", "cancel": "Zrušiť", "submit": "Odoslať",
            "idle": "Nečinné", "starting": "Spúšťa sa", "on_device_format": "Na %@", "audio_failed_format": "Zlyhanie zvuku: %@", "receiver_idle": "Nečinné", "receiver_scanning": "Skenovanie", "receiver_syncing": "Synchronizácia", "receiver_streaming": "Prehrávanie", "receiver_pin_required": "Vyžaduje sa PIN", "receiver_unknown": "Neznáme",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Expertný panel", "receiver_state": "Stav prijímača", "broadcast": "Vysielanie", "source": "Zdroj", "pa_sync": "PA synchronizácia", "enc_label": "Šifr.", "bis": "BIS", "connected_device": "Pripojené zariadenie", "advanced_actions": "Príkazy prijímača", "query_sync": "Zistiť synchronizáciu", "start_scan": "Spustiť skenovanie", "stop_scan": "Zastaviť skenovanie", "sync_selected": "Synchronizovať vybrané", "stop_sync": "Zastaviť synchronizáciu", "command": "Príkaz", "send": "Odoslať", "session_log": "Denník relácie", "clear": "Vymazať", "serial": "Sériové", "baud_rate_format": "Prenosová rýchlosť: %d", "append_carriage_return": "Pridať CR", "append_newline": "Pridať nový riadok", "next": "Ďalej", "next_description": "Táto aplikácia je najprv nastavená na CDC sériové ovládanie a analýzu odpovedí Auracast. Keď bude spojenie so zariadením stabilné, môžeme pridať vyššie pracovné postupy prijímača."
        ],
        "sv": [
            "device_connected": "Enhet ansluten", "no_device_connected": "Ingen enhet ansluten", "audio_input_permission_format": "Behörighet för ljudingång: %@",
            "permission_granted": "Beviljad", "permission_denied": "Nekad", "permission_requesting": "Begärs", "permission_restricted": "Begränsad", "permission_unknown": "Okänd",
            "show_expert_panel": "Visa expertpanel", "hide_expert_panel": "Dölj expertpanel", "broadcasts": "Sändningar", "scanning": "Skannar",
            "scanning_for_broadcasts": "Söker efter sändningar...", "connect_receiver_to_begin_scanning": "Anslut mottagaren för att börja söka.", "support": "Support", "copyright": "Copyright © 2026 Flairmesh Technologies",
            "pin_required": "PIN krävs", "enter_pin_for_broadcast_format": "Ange PIN för %@.", "this_broadcast": "den här sändningen", "pin_code": "PIN-kod", "cancel": "Avbryt", "submit": "Skicka",
            "idle": "Vilande", "starting": "Startar", "on_device_format": "På %@", "audio_failed_format": "Ljudfel: %@", "receiver_idle": "Vilande", "receiver_scanning": "Skannar", "receiver_syncing": "Synkroniserar", "receiver_streaming": "Spelar upp", "receiver_pin_required": "PIN krävs", "receiver_unknown": "Okänd",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Expertpanel", "receiver_state": "Mottagarstatus", "broadcast": "Sändning", "source": "Källa", "pa_sync": "PA-synk", "enc_label": "Kryp.", "bis": "BIS", "connected_device": "Ansluten enhet", "advanced_actions": "Mottagarkommandon", "query_sync": "Fråga synk", "start_scan": "Starta skanning", "stop_scan": "Stoppa skanning", "sync_selected": "Synka vald", "stop_sync": "Stoppa synk", "command": "Kommando", "send": "Skicka", "session_log": "Sessionslogg", "clear": "Rensa", "serial": "Seriell", "baud_rate_format": "Baudhastighet: %d", "append_carriage_return": "Lägg till carriage return", "append_newline": "Lägg till ny rad", "next": "Nästa", "next_description": "Den här appen är först konfigurerad för CDC-seriekontroll och Auracast-svarstolkning. Vi kan lägga till mer avancerade mottagarflöden när enhetslänken är stabil."
        ],
        "fi": [
            "device_connected": "Laite yhdistetty", "no_device_connected": "Laitetta ei ole yhdistetty", "audio_input_permission_format": "Äänitulon lupa: %@",
            "permission_granted": "Myönnetty", "permission_denied": "Estetty", "permission_requesting": "Pyydetään", "permission_restricted": "Rajoitettu", "permission_unknown": "Tuntematon",
            "show_expert_panel": "Näytä asiantuntijapaneeli", "hide_expert_panel": "Piilota asiantuntijapaneeli", "broadcasts": "Lähetykset", "scanning": "Etsitään",
            "scanning_for_broadcasts": "Etsitään lähetyksiä...", "connect_receiver_to_begin_scanning": "Aloita etsintä liittämällä vastaanotin.", "support": "Tuki", "copyright": "Tekijänoikeus © 2026 Flairmesh Technologies",
            "pin_required": "PIN vaaditaan", "enter_pin_for_broadcast_format": "Anna PIN lähetykselle %@.", "this_broadcast": "tälle lähetykselle", "pin_code": "PIN-koodi", "cancel": "Peruuta", "submit": "Lähetä",
            "idle": "Lepotila", "starting": "Käynnistyy", "on_device_format": "Laitteessa %@", "audio_failed_format": "Äänivirhe: %@", "receiver_idle": "Lepotila", "receiver_scanning": "Etsitään", "receiver_syncing": "Synkronoidaan", "receiver_streaming": "Toistetaan", "receiver_pin_required": "PIN vaaditaan", "receiver_unknown": "Tuntematon",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Asiantuntijapaneeli", "receiver_state": "Vastaanottimen tila", "broadcast": "Lähetys", "source": "Lähde", "pa_sync": "PA-synk", "enc_label": "Salaus", "bis": "BIS", "connected_device": "Yhdistetty laite", "advanced_actions": "Vastaanottimen komennot", "query_sync": "Kysy synkronointi", "start_scan": "Aloita etsintä", "stop_scan": "Pysäytä etsintä", "sync_selected": "Synkronoi valittu", "stop_sync": "Pysäytä synkronointi", "command": "Komento", "send": "Lähetä", "session_log": "Istuntoloki", "clear": "Tyhjennä", "serial": "Sarja", "baud_rate_format": "Baudinopeus: %d", "append_carriage_return": "Lisää CR", "append_newline": "Lisää uusi rivi", "next": "Seuraava", "next_description": "Tämä sovellus on ensin määritetty CDC-sarjahallintaan ja Auracast-vastausten jäsentämiseen. Voimme lisätä korkeamman tason vastaanotinvirtauksia, kun laiteyhteys on vakaa."
        ],
        "nb": [
            "device_connected": "Enhet tilkoblet", "no_device_connected": "Ingen enhet tilkoblet", "audio_input_permission_format": "Tillatelse for lydinngang: %@",
            "permission_granted": "Tillatt", "permission_denied": "Avslått", "permission_requesting": "Ber om", "permission_restricted": "Begrenset", "permission_unknown": "Ukjent",
            "show_expert_panel": "Vis ekspertpanel", "hide_expert_panel": "Skjul ekspertpanel", "broadcasts": "Sendinger", "scanning": "Skanner",
            "scanning_for_broadcasts": "Søker etter sendinger...", "connect_receiver_to_begin_scanning": "Koble til mottakeren for å starte søk.", "support": "Støtte", "copyright": "Opphavsrett © 2026 Flairmesh Technologies",
            "pin_required": "PIN kreves", "enter_pin_for_broadcast_format": "Skriv inn PIN for %@.", "this_broadcast": "denne sendingen", "pin_code": "PIN-kode", "cancel": "Avbryt", "submit": "Send",
            "idle": "Inaktiv", "starting": "Starter", "on_device_format": "På %@", "audio_failed_format": "Lydfeil: %@", "receiver_idle": "Inaktiv", "receiver_scanning": "Skanner", "receiver_syncing": "Synkroniserer", "receiver_streaming": "Spiller av", "receiver_pin_required": "PIN kreves", "receiver_unknown": "Ukjent",
            "live": "LIVE", "sync": "SYNC", "enc": "ENC", "expert_panel": "Ekspertpanel", "receiver_state": "Mottakerstatus", "broadcast": "Sending", "source": "Kilde", "pa_sync": "PA-synk", "enc_label": "Kryp.", "bis": "BIS", "connected_device": "Tilkoblet enhet", "advanced_actions": "Mottakerkommandoer", "query_sync": "Spør synk", "start_scan": "Start skanning", "stop_scan": "Stopp skanning", "sync_selected": "Synkroniser valgt", "stop_sync": "Stopp synk", "command": "Kommando", "send": "Send", "session_log": "Øktlogg", "clear": "Tøm", "serial": "Seriell", "baud_rate_format": "Baudrate: %d", "append_carriage_return": "Legg til carriage return", "append_newline": "Legg til ny linje", "next": "Neste", "next_description": "Denne appen er først satt opp for CDC-seriellkontroll og Auracast-responsanalyse. Vi kan legge til mer avanserte mottakerflyter når enhetskoblingen er stabil."
        ]
    ]

    static func t(_ key: String) -> String {
        strings[currentLanguage]?[key] ?? strings["en"]?[key] ?? key
    }

    static func f(_ key: String, _ arguments: CVarArg...) -> String {
        let format = t(key)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }

    static func permissionStatus(_ status: String) -> String {
        switch status {
        case "Granted": return t("permission_granted")
        case "Denied": return t("permission_denied")
        case "Requesting": return t("permission_requesting")
        case "Restricted": return t("permission_restricted")
        default: return t("permission_unknown")
        }
    }

    static func receiverState(_ state: ReceiverState) -> String {
        switch state {
        case .idle: return t("receiver_idle")
        case .scanning: return t("receiver_scanning")
        case .syncing: return t("receiver_syncing")
        case .streaming: return t("receiver_streaming")
        case .pinRequest: return t("receiver_pin_required")
        case .unknown: return t("receiver_unknown")
        }
    }

    static func audioStatus(_ status: String) -> String {
        if status == "Idle" { return t("idle") }
        if status == "Starting" { return t("starting") }
        if status.hasPrefix("On ") {
            return f("on_device_format", String(status.dropFirst(3)))
        }
        if status.hasPrefix("Audio failed: ") {
            return f("audio_failed_format", String(status.dropFirst("Audio failed: ".count)))
        }
        return status
    }

    private static var currentLanguage: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.hasPrefix("zh-Hans") { return "zh-Hans" }
        if preferred.hasPrefix("zh-Hant") { return "zh-Hant" }
        if preferred.hasPrefix("pt-BR") { return "pt-BR" }
        if preferred.hasPrefix("nb") || preferred.hasPrefix("no") { return "nb" }
        let code = preferred.components(separatedBy: "-").first ?? "en"
        return strings[code] != nil ? code : "en"
    }
}
