# initialization
window.onload = () ->
  $.container = $('#container')
  $.WIDTH = $.container.width()
  $.HEIGHT = $.container.height()

  # create renderer
  $.renderer = new THREE.WebGLRenderer()
  $.renderer.setSize($.WIDTH, $.HEIGHT)
  $.container.append($.renderer.domElement)

  # initialize scene
  $.scene = new THREE.Scene()

  # create camera
  $.camera = new THREE.PerspectiveCamera(45, $.WIDTH / $.HEIGHT, 0.1, 20)
  $.camera.position.z = 5
  $.scene.add($.camera)

  # add lights
  pointLight = new THREE.PointLight(0xCCFFFF)
  pointLight.position.x = 5
  pointLight.position.y = 20
  pointLight.position.z = 15
  $.scene.add(pointLight)

  pointLight = new THREE.PointLight(0xFFCCFF)
  pointLight.position.x = -5
  pointLight.position.y = -20
  pointLight.position.z = -15
  $.scene.add(pointLight)

  pointLight = new THREE.PointLight(0xFFFFCC)
  pointLight.position.x = 5
  pointLight.position.y = -20
  pointLight.position.z = 15
  $.scene.add(pointLight)

  # init controls
  $.controls = new THREE.TrackballControls($.camera, $.container[0]);
  $.controls.rotateSpeed = 1.0;
  $.controls.zoomSpeed = 1.2;
  $.controls.panSpeed = 0.8;
  $.controls.noZoom = false;
  $.controls.noPan = false;
  $.controls.staticMoving = true;
  $.controls.dynamicDampingFactor = 0.3;

  # for checking mouse clicks
  $.projector = new THREE.Projector();
  $.points = []
  $.stone_spheres = []
  $.container[0].addEventListener('mousedown', onDocumentMouseDown, false)

  $.active_stones = []

  # antialiasing
  # dpr = 1;
  # if (window.devicePixelRatio != undefined)
  #   dpr = window.devicePixelRatio;

  # renderScene = new THREE.RenderPass($.scene, $.camera);
  # effectFXAA = new THREE.ShaderPass(THREE.FXAAShader);
  # effectFXAA.uniforms['resolution'].value.set(1 / ($.WIDTH * dpr), 1 / ($.HEIGHT * dpr));
  # effectFXAA.renderToScreen = true;

  # $.composer = new THREE.EffectComposer($.renderer);
  # $.composer.setSize($.WIDTH * dpr, $.HEIGHT * dpr);
  # $.composer.addPass(renderScene);
  # $.composer.addPass(effectFXAA);
  # $.composer.render()

  # start
  $.animate()

# rendering loop <- probably overkill
$.animate = () ->
  requestAnimationFrame($.animate)
  $.renderer.render($.scene, $.camera)
#  $.controls.update()

#  $.renderer.clear()
#  if $.composer
#    alert(1)
#    $.composer.render()


# draph initial graph
$.initScene = (game) ->
  
  $.graph = new THREE.Object3D();
  $.scene.add($.graph);

  # draw dots
  for point in game.board.points
    pt = getPoint(0.7 * game.board.stone_radius, point.pos[0], point.pos[1], point.pos[2])
    $.graph.add(pt)
    $.points.push(pt)

  # draw edges
  material = new THREE.LineBasicMaterial({color: 0x334455, linewidth: 2})
  for edge in game.board.edges
    p0 = (p.pos for p in game.board.points when p.point_id == edge.connection[0])[0]
    p1 = (p.pos for p in game.board.points when p.point_id == edge.connection[1])[0]
  
    geometry = new THREE.Geometry()
    geometry.vertices.push( new THREE.Vector3(p0[0], p0[1], p0[2]) );
    geometry.vertices.push( new THREE.Vector3(p1[0], p1[1], p1[2]) );

    edge = new THREE.Line(geometry, material)
    $.graph.add(edge)

  # draw existing stones
  $.updateStones()
  

# return a point
getPoint = (size, x, y, z) ->
  material = new THREE.MeshPhongMaterial({specular: 0xAA0000, color: 0x990000, emissive: 0x660000, shininess: 30})
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

  game = $.currentGame()

  # setup raycaster
  vector = new THREE.Vector3( ( event.clientX / $.WIDTH ) * 2 - 1, - ( event.clientY / $.HEIGHT ) * 2 + 1, 0.5 )
  $.projector.unprojectVector( vector, $.camera )
  raycaster = new THREE.Raycaster( $.camera.position, vector.sub( $.camera.position ).normalize() )

  # intersect for capturing stones
  intersects = raycaster.intersectObjects($.stone_spheres)

  if intersects.length > 0
    obj = intersects[0].object
    $.pos = pos = [obj.position.x, obj.position.y, obj.position.z]
    point_id = [pt.point_id for pt in game.board.points when pt.pos[0] == pos[0] && pt.pos[1] == pos[1] && pt.pos[2] == pos[2]][0][0]

    share.captureStone(game, point_id)
    return

  # can only do things if it's your turn
  #if not $.isCurrentTurn(Meteor.user())
  #  return

  # intersect for stone placement
  intersects = raycaster.intersectObjects($.points)

  if intersects.length > 0
    $.pos = pos = [intersects[0].object.position.x, intersects[0].object.position.y, intersects[0].object.position.z]
    point_id = [pt.point_id for pt in game.board.points when pt.pos[0] == pos[0] && pt.pos[1] == pos[1] && pt.pos[2] == pos[2]][0][0]
    share.playStone(game, point_id)


# add a black stone
addBlackStone = (size, x, y, z) ->
  material = new THREE.MeshPhongMaterial({specular: 0x666666, color: 0x333333, emissive: 0x000000, shininess: 20})
  sphere = getSphere(size, x, y, z, material)
  $.stone_spheres.push(sphere)
  $.graph.add(sphere)


# add a white stone
addWhiteStone = (size, x, y, z) ->
  material = new THREE.MeshPhongMaterial({specular: 0xFFFFFF, color: 0xBBBBBB, emissive: 0x444444, shininess: 40})
  sphere = getSphere(size, x, y, z, material)
  $.stone_spheres.push(sphere)
  $.graph.add(sphere)


# update stones
$.updateStones = () ->
  game = $.currentGame()

  # remove all stones
  for sphere in $.stone_spheres
    $.graph.remove(sphere)

  $.stone_spheres = [] 

  # draw stones
  for stone in game.stones
    if stone.captured
      continue

    id = stone.point_id
    pos = [pt.pos for pt in game.board.points when pt.point_id == id][0][0]
    if stone.player == 'black'
      addBlackStone(game.board.stone_radius, pos[0], pos[1], pos[2])
    else
      addWhiteStone(game.board.stone_radius, pos[0], pos[1], pos[2])
