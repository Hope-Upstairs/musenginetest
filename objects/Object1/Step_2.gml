var w = window_get_width()
var h = window_get_height()

if (old_width == w) and (old_height == h) exit

old_width = w
old_height = h

surface_resize(application_surface,w,h)
view_wport[0] = w
view_hport[0] = h
camera_set_view_size(view_camera[0],w,h)