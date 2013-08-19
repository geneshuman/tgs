# initialization
window.onload = () ->
  container = $('#3D')
  WIDTH = container.width()
  HEIGHT = container.height()

  # create renderer
  $.renderer = new THREE.WebGLRenderer()
  $.renderer.setSize(WIDTH, HEIGHT)
  container.append($.renderer.domElement)

  # initialize scene
  $.scene = new THREE.Scene()

  # create camera
  $.camera = new THREE.PerspectiveCamera(45, WIDTH / HEIGHT, 0.1, 20)
  $.camera.position.z = 5
  $.scene.add($.camera)

  # add light
  pointLight = new THREE.PointLight(0xFFFFFF)
  pointLight.position.x = 5
  pointLight.position.y = 25
  pointLight.position.z = 70
  $.scene.add(pointLight)

  # init controls
  $.controls = new THREE.TrackballControls($.camera);
  $.controls.rotateSpeed = 1.0;
  $.controls.zoomSpeed = 1.2;
  $.controls.panSpeed = 0.8;
  $.controls.noZoom = false;
  $.controls.noPan = false;
  $.controls.staticMoving = true;
  $.controls.dynamicDampingFactor = 0.3;
#  $.animate()

  # for checking mouse clicks
  $.projector = new THREE.Projector();
  $.points = []
  document.addEventListener('mousedown', onDocumentMouseDown, false)


# rendering loop <- probably overkill
$.animate = () ->
  requestAnimationFrame($.animate)
  $.renderer.render($.scene, $.camera)
  $.controls.update()


# draph initial graph
$.initScene = (game) ->
  window.game = game
  
  $.graph = new THREE.Object3D();
  $.scene.add($.graph);

  # draw dots
  for point in game.board.points
    pt = getPoint(0.7 * game.board.stone_radius, point.pos[0], point.pos[1], point.pos[2])
    $.graph.add(pt)
    $.points.push([pt, point])

  # draw edges
  material = new THREE.LineBasicMaterial({color: 0x000000})
  for edge in game.board.edges
    p0 = (p.pos for p in game.board.points when p.point_id == edge.connection[0])[0]
    p1 = (p.pos for p in game.board.points when p.point_id == edge.connection[1])[0]
  
    geometry = new THREE.Geometry()
    geometry.vertices.push( new THREE.Vector3(p0[0], p0[1], p0[2]) );
    geometry.vertices.push( new THREE.Vector3(p1[0], p1[1], p1[2]) );

    edge = new THREE.Line(geometry, material)
    $.graph.add(edge)

  $.renderer.render($.scene, $.camera)  

# return a point
getPoint = (size, x, y, z) ->
  material = new THREE.MeshLambertMaterial({color: 0xCC0000})
  getSphere(size, x, y, z, material)


# return a sphere
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


# check for mouse clicks on stones
onDocumentMouseDown = (event) ->
  event.preventDefault();

  vector = new THREE.Vector3( ( event.clientX / 400 ) * 2 - 1, - ( event.clientY / 400 ) * 2 + 1, 0.5 )
  $.projector.unprojectVector( vector, $.camera )

  raycaster = new THREE.Raycaster( $.camera.position, vector.sub( $.camera.position ).normalize() )

  tmp = []
  for e in $.points
    tmp.push(e[0])

  intersects = raycaster.intersectObjects(tmp)

  if intersects.length > 0
    intersects[ 0 ].object.material.color.setHex( Math.random() * 0xffffff )


# add a black stone
addBlackStone = (size, x, y, z) ->
  material = new THREE.MeshLambertMaterial({color: 0x000000})
  $.graph.add(getSphere(size, x, y, z, material))


# add a white stone
addWhiteStone = (size, x, y, z) ->
  material = new THREE.MeshLambertMaterial({color: 0xFFFFFF})
  $.graph.add(getSphere(size, x, y, z, material))