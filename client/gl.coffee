# initialize renderer & draph initial graph
$.initScene = (game) ->
  $.container = $('#glContainer')
  $.WIDTH = $.container.width()
  $.HEIGHT = $.container.height()

  # create renderer
  $.renderer = new THREE.WebGLRenderer({'antialias':true})
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
  $.container[0].addEventListener('mousedown', onDocumentMouseDown, false)

  # anialiasing?
#  $.composer = new THREE.EffectComposer($.renderer)
#  $.composer.addPass(new THREE.RenderPass($.scene, $.camera))

  # aux data
  $.point_spheres = []
  $.stone_spheres = []
  $.marker_spheres = []
  $.pos_to_id = {}

  # draw dots & edges
  $.graph = new THREE.Object3D();
  $.scene.add($.graph);
  
  line_material = new THREE.LineBasicMaterial({color: 0x334455, linewidth: 2})

  for id, point of game.board.points
    p0 = point.pos

    c0 = Math.round(255 * (0.30 * 0.5 * (p0[0] + 1.0) + .2))
    c1 = Math.round(255 * (0.30 * 0.5 * (p0[1] + 1.0) + .2))
    c2 = Math.round(255 * (0.30 * 0.5 * (p0[2] + 1.0) + .2))
    color = (2 << 15) * c0 + (2 << 7) * c1 + c2
    #point_material = new THREE.MeshPhongMaterial({specular: 0xAA0000, color: color, emissive: 0x660000, shininess: 30, transparent: true, opacity:0.7})
    point_material = new THREE.MeshPhongMaterial({specular: 0x888888, color: color, emissive: 0x444444, shininess: 20, transparent: true, opacity:0.7})
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

  # add resize handler
  window.addEventListener('resize', onWindowResize, false)

  # start
  $.updateStones()
  animate()


# empty scene
$.clearScene = () ->
  $('#glContainer').empty()


# resize
onWindowResize = () ->
  $.camera.aspect = $.container.width() / $.container.height()
  $.renderer.setSize($.container.width(), $.container.height())
  $.camera.updateProjectionMatrix()


# rendering loop <- probably overkill
animate = () ->
  requestAnimationFrame(animate)
  $.renderer.render($.scene, $.camera)
  $.controls.update()


# return a sphere
getSphere = (size, x, y, z, material) ->
  radius = size
  segments = 24
  rings = 24
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

  # intersect for clicking on groups
  block_intersects = raycaster.intersectObjects(_.union($.stone_spheres, $.marker_spheres))
  valid_intersects = raycaster.intersectObjects($.point_spheres)

  valid = valid_intersects[0]
  block = block_intersects[0]

  if block && (!valid || block.distance < valid.distance)
    obj = block.object
    pos = [obj.position.x, obj.position.y, obj.position.z]
    point_id = $.pos_to_id[pos]
    share.clickStone(game, point_id)
    return

  # can only place stones if it's your turn
  if not $.isCurrentTurn(Meteor.user())
    return

  if valid
    obj = valid.object
    pos = [obj.position.x, obj.position.y, obj.position.z]
    point_id = $.pos_to_id[pos]
    share.playStone(game, point_id)


# add a stone
addStone = (color, size, x, y, z) ->
  if color == "black"
    material = new THREE.MeshPhongMaterial({specular: 0x666666, color: 0x333333, emissive: 0x000000, shininess: 20})
  else if color == "white"
    material = new THREE.MeshPhongMaterial({specular: 0xFFFFFF, color: 0xBBBBBB, emissive: 0x444444, shininess: 40})
  else if color == "ko"
    material = new THREE.MeshPhongMaterial({specular: 0xAAAAFF, color: 0x3333BB, emissive: 0x222244, shininess: 80})
  else if color == "marker"
    material = new THREE.MeshPhongMaterial({specular: 0xFFAAAA, color: 0xBB3333, emissive: 0x442222, shininess: 80, transparent: true, opacity:0.7})

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

  # remove all markers
  for sphere in $.marker_spheres
    $.graph.remove(sphere)

  $.marker_spheres = [] 

  # draw stones
  for stone in game.stones
    if stone.captured
      continue

    id = stone.point_id
    pos = game.board.points[stone.point_id].pos
    addStone(stone.player, game.board.stone_radius, pos[0], pos[1], pos[2])

  # mark ko points
  for point_id in game.ko_points
    pos = game.board.points[point_id].pos
    addStone("ko", 0.8 * game.board.stone_radius, pos[0], pos[1], pos[2])

  # draw marked stones
  for id, group of game.groups
    if !group.marked_dead
      continue
    for point_id in group.members
      pos = game.board.points[point_id].pos
      addStone("marker", 1.2 * game.board.stone_radius, pos[0], pos[1], pos[2])
