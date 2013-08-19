window.onload = () ->
  WIDTH = 400
  HEIGHT = 300

  VIEW_ANGLE = 45
  ASPECT = WIDTH / HEIGHT
  NEAR = 0.1
  FAR = 10000

  # create renderer
  $.renderer = new THREE.WebGLRenderer({ antialiasing: true })
  $.renderer.setSize(WIDTH, HEIGHT)
  $('#3D').append($.renderer.domElement)

  # initialize scene
  $.scene = new THREE.Scene()

  # create camera
  $.camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
  $.camera.position.z = 300

  $.scene.add($.camera)


  pointLight = new THREE.PointLight(0xFFFFFF)

  pointLight.position.x = 10
  pointLight.position.y = 50
  pointLight.position.z = 130

  $.scene.add(pointLight)

  $.renderer.render($.scene, $.camera)


$.initScene = (game) ->
  alert(game)
  radius = 50
  segments = 16
  rings = 16

  sphereMaterial = new THREE.MeshLambertMaterial(
    {
      color: 0xCC0000
    })

  sphere = new THREE.Mesh(
    new THREE.SphereGeometry(
      radius,
      segments,
      rings),
    sphereMaterial)

  $.scene.add(sphere);

  $.renderer.render($.scene, $.camera)
