# initialize renderer & draph initial graph
$.initScene = (game) ->
  $.container = $('#glContainer')
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
  $.point_spheres = []
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
  animate()
  
  $.graph = new THREE.Object3D();
  $.scene.add($.graph);

  # draw dots & edges
  point_material = new THREE.MeshPhongMaterial({specular: 0xAA0000, color: 0x990000, emissive: 0x660000, shininess: 30, transparent: true, opacity:0.7})
  line_material = new THREE.LineBasicMaterial({color: 0x334455, linewidth: 2})
  $.pos_to_id = {}

  for id, point of game.board.points
    p0 = point.pos

    pt = getSphere(0.65 * game.board.stone_radius, p0[0], p0[1], p0[2], point_material)
    $.graph.add(pt)
    $.point_spheres.push(pt)

    $.pos_to_id[p0] = id

    # edges    
    for neighbor in point.neighbors
      p1 = game.board.points[neighbor].pos

      geometry = new THREE.Geometry()
      geometry.vertices.push( new THREE.Vector3(p0[0], p0[1], p0[2]) );
      geometry.vertices.push( new THREE.Vector3(p1[0], p1[1], p1[2]) );

      edge = new THREE.Line(geometry, line_material)
      $.graph.add(edge)    

  # draw existing stones
  $.updateStones()


# empty scene
$.clearScene = () ->
  $('#glContainer').empty()


# rendering loop <- probably overkill
animate = () ->
  requestAnimationFrame(animate)
  $.renderer.render($.scene, $.camera)
  $.controls.update()

#  $.renderer.clear()
#  if $.composer
#    alert(1)
#    $.composer.render()



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
    point_id = $.pos_to_id[[obj.position.x, obj.position.y, obj.position.z]]
#    share.clickStone(game, point_id)
    return

  # can only do things if it's your turn
  if not $.isCurrentTurn(Meteor.user())
    return

  # intersect for stone placement
  intersects = raycaster.intersectObjects($.point_spheres)

  if intersects.length > 0
    pos = [intersects[0].object.position.x, intersects[0].object.position.y, intersects[0].object.position.z]
    share.playStone(game, $.pos_to_id[pos])


# add a black stone
addStone = (color, size, x, y, z) ->
  if color == "black"
    material = new THREE.MeshPhongMaterial({specular: 0x666666, color: 0x333333, emissive: 0x000000, shininess: 20})
  else if color == "white"
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
    pos = game.board.points[stone.point_id].pos
    addStone(stone.player, game.board.stone_radius, pos[0], pos[1], pos[2])