extends Button

func _pressed():
    EventBus.skip_crushable.emit()
