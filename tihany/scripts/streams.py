#!python3
from flask import Flask, request, jsonify, abort, render_template, redirect, url_for
import os, sqlite3, signal
from rfc3986 import uri_reference
SELF_IP = os.environ.get("SELF_IP")
RTSP_PORT = int(os.environ.get("RTSP_PORT"))

def get_db():
    DB = os.environ.get("DB")
    return sqlite3.connect(DB)

app = Flask(__name__, static_url_path='/static')

def get_ids():
    db = get_db()
    c = db.cursor()
    return [ row[0] for row in c.execute('SELECT id FROM streams ORDER by id') ]

def get_streams():
    db = get_db()
    c = db.cursor()
    return [ {'id': row[0], 'url': row[1]} for row in c.execute('SELECT id,url FROM streams ORDER by id') ]

@app.route('/api/streams', methods=['GET'])
@app.route('/api/streams/', methods=['GET'])
def api_get_streams():
    return jsonify(get_streams())
        
@app.route('/api/streams/<id>', methods=['GET'])
def get_stream(id):
    db = get_db()
    c = db.cursor()
    row = c.execute('SELECT id,url FROM streams where id=:id', {'id':id}).fetchall()
    if len(row) == 1:
        return jsonify({'id': row[0][0], 'url': row[0][1]})
    if len(row) == 0:
        abort(404)
    abort(500)
    
def create_stream(id, url):
    if id and url and uri_reference(url).is_valid:
        db = get_db()
        c = db.cursor()
        if len(c.execute('SELECT id,url FROM streams where id=:id', {'id':id}).fetchall()) == 0:
            c.execute('INSERT into streams (id,url) VALUES (:id,:url)', {'id':id, 'url':url})
            db.commit()
            return True
    return False
    
@app.route('/api/streams/', methods=['POST'])
def post_stream():
    data = request.get_json(force=True)
    if create_stream(**data):
        return get_stream(data['id'])
    abort(400)

@app.route('/api/streams/<id>', methods=['DELETE'])
def delete_stream(id):
    db = get_db()
    c = db.cursor()
    c.execute('DELETE FROM streams where id=:id', {'id':id})
    db.commit()
    return "deleted", 204

@app.route('/restart', methods=['POST'])
def restart():
    pidfile = os.environ.get("LIVEPIDFILE")
    s = open(pidfile, 'r').read()
    pid = int(s)
    print("kill %d"%(pid))
    os.kill(pid, signal.SIGINT)
    return redirect('/')

@app.route('/')
@app.route('/streams/')
@app.route('/streams')
def start_page():
    nextid = sorted(set(range(1, 10)) - set(get_ids()))[0]
    streams = []
    proxy_id = 1
    prev = None
    for stream in get_streams():
        if prev:
            stream['prev'] = prev['id']
            prev['next'] = stream['id']
        else:
            stream['prev'] = None
        stream['proxy_url'] = 'rtsp://%s:%d/proxyStream-%d' % (SELF_IP, RTSP_PORT, proxy_id)
        proxy_id = proxy_id + 1
        streams.append(stream)
        prev = stream
    return render_template('streams.html', streams=streams, nextid=nextid)
    


def swap(id1, id2):
    db = get_db()
    c = db.cursor()
    c.execute('UPDATE streams SET id=:id1 WHERE id=:id2', {'id1':99, 'id2':id1})
    c.execute('UPDATE streams SET id=:id1 WHERE id=:id2', {'id1':id1, 'id2':id2})
    c.execute('UPDATE streams SET id=:id1 WHERE id=:id2', {'id1':id2, 'id2':99})
    db.commit()

@app.route('/action', methods=['POST'])
def action():
    print(request.form)
    if request.form['action'] == 'delete':
        if request.form['id']:
            if delete_stream(request.form['id'])[1] == 204:
                pass
    elif request.form['action'] == 'up':
        if request.form['id'] and request.form['prev']:
            swap(request.form['id'], request.form['prev'])
    elif request.form['action'] == 'down':
        if request.form['id'] and request.form['next']:
            swap(request.form['id'], request.form['next'])
         
    return redirect('/')

@app.route('/add', methods=['POST'])
def add():
    if request.form['id'] and request.form['url']:
        if create_stream(request.form['id'], request.form['url']):
            pass
    return redirect('/')
    
app.debug = True
app.run(host='0.0.0.0', port=8080, use_reloader=True)

