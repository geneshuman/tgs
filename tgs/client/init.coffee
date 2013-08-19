window.onload = () ->
  WIDTH = 400
  HEIGHT = 400

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
  $.camera.position.z = 2

  $.scene.add($.camera)


  pointLight = new THREE.PointLight(0xFFFFFF)

  pointLight.position.x = 10
  pointLight.position.y = 50
  pointLight.position.z = 130

  $.scene.add(pointLight)

  $.renderer.render($.scene, $.camera)


$.initScene = (game) ->
  window.game = game
  for point in game.board.points
    pos = point.pos
    drawPoint(game.board.stone_radius, pos[0], pos[1], pos[2])


drawPoint = (size, x, y, z) ->
  material = new THREE.MeshLambertMaterial(
    {
      color: 0xCC0000
    })
  drawSphere(size, x, y, z, material)


drawSphere = (size, x, y, z, material) ->
  radius = size
  segments = 16
  rings = 16
  sphere = new THREE.Mesh(
    new THREE.SphereGeometry(
      size,
      segments,
      rings),
    material)

  $.scene.add(sphere);

  $.renderer.render($.scene, $.camera)
