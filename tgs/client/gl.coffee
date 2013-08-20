# initialization
window.onload = () ->
  container = $('#container')
  $.WIDTH = container.width()
  $.HEIGHT = container.height()

  # create renderer
  $.renderer = new THREE.WebGLRenderer()
  $.renderer.setSize($.WIDTH, $.HEIGHT)
  container.append($.renderer.domElement)

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
  $.controls = new THREE.TrackballControls($.camera);
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
  document.addEventListener('mousedown', onDocumentMouseDown, false)

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
  $.controls.update()

#  $.renderer.clear()
#  if $.composer
#    alert(1)
#    $.composer.render()


# draph initial graph
$.initScene = (game) ->
  $.game = game
  
  $.graph = new THREE.Object3D();
  $.scene.add($.graph);

  # draw dots
  for point in game.board.points
    alert(game.board.stone_radius)
    pt = getPoint(0.7 * game.board.stone_radius, point.pos[0], point.pos[1], point.pos[2])
    $.graph.add(pt)
    $.points.push([pt, point])

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

  vector = new THREE.Vector3( ( event.clientX / $.WIDTH ) * 2 - 1, - ( event.clientY / $.HEIGHT ) * 2 + 1, 0.5 )
  $.projector.unprojectVector( vector, $.camera )

  raycaster = new THREE.Raycaster( $.camera.position, vector.sub( $.camera.position ).normalize() )

  tmp = []
  for e in $.points
    tmp.push(e[0])

  intersects = raycaster.intersectObjects(tmp)

  if intersects.length > 0
    point_id = [pt[1].point_id for pt in $.points when pt[0] == intersects[0].object][0][0]
    share.playStone($.game, point_id)


# add a black stone
addBlackStone = (size, x, y, z) ->
  material = new THREE.MeshPhongMaterial({specular: 0x666666, color: 0x333333, emissive: 0x000000, shininess: 20})
  $.graph.add(getSphere(size, x, y, z, material))


# add a white stone
addWhiteStone = (size, x, y, z) ->
  material = new THREE.MeshPhongMaterial({specular: 0xFFFFFF, color: 0xBBBBBB, emissive: 0x444444, shininess: 40})
  $.graph.add(getSphere(size, x, y, z, material))


# draw last stone
$.drawLastStone = () ->
  id = $.game.stones[$.game.stones.length - 1]
  pos = [pt.pos for pt in $.game.board.points when pt.point_id == id][0][0]

  if $.game.stones.length % 2 == 1
    addBlackStone($.game.board.stone_radius, pos[0], pos[1], pos[2])
  else
    addWhiteStone($.game.board.stone_radius, pos[0], pos[1], pos[2])