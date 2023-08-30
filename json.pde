/**
 * All functions for parsing JSON data files.
 */

/**
 * Takes the JSON file pointed to by <path> and initializes important
 * global variables (e.g. <sprite_map>) with the data contained within.
 */
void initFromJSON(String path)
{
  json = loadJSONObject(path);
  String archetype = json.getString("archetype");
  println("Loading JSON with archetype: " + archetype);
  if        (archetype.equals("SPRITES")) {
    parseSpritesJSON(json);
  } else if (archetype.equals("TILES")) {
    parseTilesJSON(json);
  } else if (archetype.equals("PROPS")) {
    parsePropsJSON(json);
  } else if (archetype.equals("LIGHTING")) {
    parseLightingJSON(json);
  } else {
    println("initFromJSON(): Archetype \"" + archetype + "\" not found.");
  }
}

/**
 * Parses the data stored in a JSON with the archetype "SPRITES" and updates
 * <sprite_map> accordingly.
 */
void parseSpritesJSON(JSONObject json)
{
  sprite_map = new HashMap<String, Sprite>();
  
  JSONArray jsprites = json.getJSONArray("sprites");
  for (int i = 0; i < jsprites.size(); ++i) {
    JSONObject jsprite = jsprites.getJSONObject(i);
    String jpath       = jsprite.getString("path");
    String jzd_path    = null;
    if (!jsprite.isNull("zd_path")) // this sprite does have zd data
      jzd_path         = jsprite.getString("zd_path");
    String jname       = jsprite.getString("name");
    int jzd_offset     = 0;
    if (!jsprite.isNull("zd_offset")) // this sprite does have zd data
      jzd_offset       = jsprite.getInt("zd_offset");
    
    PImage pi = loadImage(jpath);
    PImage zd = null;
    if (jzd_path != null)
      zd = loadImage(jzd_path);
    Sprite sp = new Sprite(pi, zd, jname, jzd_offset);
    
    // Sprite data goes into a map from names -> Sprites
    sprite_map.put(jname, sp);
  }
}

/**
 * Parses the data stored in a JSON with the archetype "TILES" and updates
 * <tiles> accordingly.
 */
void parseTilesJSON(JSONObject json)
{
  tiles = new ArrayList<Tile>();
  
  JSONArray jtiles = json.getJSONArray("tiles");
  for (int i = 0; i < jtiles.size(); ++i) {
    JSONObject jtile = jtiles.getJSONObject(i);
    String jsprite   = jtile.getString("sprite");
    JSONArray jpos   = jtile.getJSONArray("pos");
    PVector pos      = new PVector(
      jpos.getFloat(0),
      jpos.getFloat(1),
      jpos.getFloat(2)
    );
    // jpos was stored in tile coordinates, so we need to convert to world coordinates
    pos = pv_scale(pos, TILE_SIDE_LENGTH);
    
    Tile t = new Tile(jsprite, pos);
    tiles.add(t);
  }
}

/**
 * Parses the data stored in a JSON with the archetype "PROPS" and updates
 * <props> accordingly.
 */
void parsePropsJSON(JSONObject json)
{
  props = new ArrayList<Prop>();
  
  JSONArray jprops = json.getJSONArray("props");
  for (int i = 0; i < jprops.size(); ++i) {
    JSONObject jprop = jprops.getJSONObject(i);
    String jsprite     = jprop.getString("sprite");
    JSONArray jpos     = jprop.getJSONArray("pos");
    PVector pos        = new PVector(
      jpos.getFloat(0),
      jpos.getFloat(1),
      jpos.getFloat(2)
    );
    // jpos was stored in tile coordinates, so we need to convert to world coordinates
    pos = pv_scale(pos, TILE_SIDE_LENGTH);
    
    Prop p = new Prop(jsprite, pos);
    props.add(p);
  }
}

/**
 * Parses the data stored in a JSON with the archetype "LIGHTING" and updates
 * <ambient_light>, <directional_light>, and <directional_light_dir> accordingly.
 */
void parseLightingJSON(JSONObject json)
{
  // colors stored as float[3]
  JSONArray jambient = json.getJSONArray("ambient");
  ambient_light[0] = jambient.getFloat(0);
  ambient_light[1] = jambient.getFloat(1);
  ambient_light[2] = jambient.getFloat(2);
  
  JSONObject jdirectional = json.getJSONObject("directional");
  JSONArray  jcolor       = jdirectional.getJSONArray("color");
  directional_light[0] = jcolor.getFloat(0);
  directional_light[1] = jcolor.getFloat(1);
  directional_light[2] = jcolor.getFloat(2);
  float jazimuth   = jdirectional.getFloat("azimuth")   * PI / 180;
  float jelevation = jdirectional.getFloat("elevation") * PI / 180;
  float x     = cos(jazimuth) * cos(jelevation);
  float y     = sin(jelevation);
  float z     = sin(jazimuth) * cos(jelevation);
  directional_light_dir = new PVector(x, y, z); // wc
}
