window.onload = () ->
  WIDTH = 400
  HEIGHT = 400

  VIEW_ANGLE = 45
  ASPECT = WIDTH / HEIGHT
  NEAR = 0.1
  FAR = 10

  # create renderer
  $.renderer = new THREE.WebGLRenderer({ antialiasing: true })
  $.renderer.setSize(WIDTH, HEIGHT)
  $('#3D').append($.renderer.domElement)

  # initialize scene
  $.scene = new THREE.Scene()

  # create camera
  $.camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
  $.camera.position.z = 5

  $.scene.add($.camera)


  pointLight = new THREE.PointLight(0xFFFFFF)

  pointLight.position.x = 10
  pointLight.position.y = 50
  pointLight.position.z = 130

  $.scene.add(pointLight)

  $.renderer.render($.scene, $.camera)

  $.controls = new THREE.TrackballControls($.camera);
  $.controls.rotateSpeed = 1.0;
  $.controls.zoomSpeed = 1.2;
  $.controls.panSpeed = 0.8;
  $.controls.noZoom = false;
  $.controls.noPan = false;
  $.controls.staticMoving = true;
  $.controls.dynamicDampingFactor = 0.3;
#  $.controls.addEventListener( 'change', $.render );
  $.animate()


$.animate = () ->
#  alert($.controls)
  requestAnimationFrame($.animate)
  $.render()
  if $.controls
  	$.controls.update()


$.render = () ->
  $.renderer.render($.scene, $.camera)

$.initScene = (game) ->
  window.game = game
  
  $.graph = new THREE.Object3D();
  $.graph.rotation.set(0.1,0.2,0.3)
  $.scene.add($.graph);

  for point in game.board.points
    point = getPoint(game.board.stone_radius, point.pos[0], point.pos[1], point.pos[2])
    $.graph.add(point)

  material = new THREE.MeshLambertMaterial({color: 0x444444})
  for edge in game.board.edges
    p0 = (p.pos for p in game.board.points when p.point_id == edge.connection[0])[0]
    p1 = (p.pos for p in game.board.points when p.point_id == edge.connection[1])[0]
  
    geometry = new THREE.Geometry()
    geometry.vertices.push( new THREE.Vector3(p0[0], p0[1], p0[2]) );
    geometry.vertices.push( new THREE.Vector3(p1[0], p1[1], p1[2]) );

    edge = new THREE.Line(geometry ,material, THREE.LineStrip)
    $.graph.add(edge)

  $.renderer.render($.scene, $.camera)


getPoint = (size, x, y, z) ->
  material = new THREE.MeshLambertMaterial({color: 0xCC0000})
  getSphere(size, x, y, z, material)


getSphere = (size, x, y, z, material) ->
  radius = size
  segments = 16
  rings = 16
  sphere = new THREE.Mesh(
    new THREE.SphereGeometry(
      size,
      segments,
      rings),
    material)

  sphere.position.x = x
  sphere.position.y = y
  sphere.position.z = z

  sphere
