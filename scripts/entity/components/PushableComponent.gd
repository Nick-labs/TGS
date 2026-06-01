extends ObjectComponent
class_name PushableComponent


func try_push(object):

	if not object.has_component(
		PushableComponent
	):
		return false

	#move_object(object)

	return true
