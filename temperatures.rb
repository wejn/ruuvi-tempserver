#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'thread'
require 'webrick'

reject_unknown = false
id2name = {
    'xx:xx:xx:xx:xx:xx' => 'balkon',
    'xx:xx:xx:xx:xx:yy' => 'loznice',
    'xx:xx:xx:xx:xx:zz' => 'kancl',
}

threads = []

class TempData
    def initialize(timeout = 600.0)
        @timeout = timeout
        @mutex = Mutex.new
        @data = {}
    end

    def set(name, value, ts = Time.now)
        @mutex.synchronize do
            @data[name] = [value, ts]
        end
    end

    def get(name)
        @mutex.synchronize do
            @data[name]
        end
    end

    def get_all
        @mutex.synchronize do
            @data
        end
    end

    def get_average
        @mutex.synchronize do
            s,n = @data.inject([0, 0]) do |(sum,num), (name,(value,ts))|
                if ts+@timeout < Time.now
                    [sum, num]
                else
                    [sum+value.to_f, num+1]
                end
            end
            if n.zero?
                nil
            else
                s.to_f / n
            end
        end
    end
end

tempdata = TempData.new
for f in id2name.values
    tempdata.set(f, -50.0, Time.now - 600)
end

puts "Starting..."

def timeconv(interval)
    interval = interval.to_f
    if interval < 60
        "%.01f seconds" % interval
    elsif interval < 60*60
        "%.01f minutes" % (interval/60)
    elsif interval < 24*60*60
        "%.01f hours" % (interval/(60*60))
    else
        "%.01f days" % (interval/(24*60*60))
    end

end

threads << Thread.new do
    puts "+ Webserver..."
    s = WEBrick::HTTPServer.new({
        :Port => 8000,
        :BindAddress => "0.0.0.0",
        :Logger => WEBrick::Log.new('/dev/null'),
        #:AccessLog => [ [File.open('/dev/null', 'w'), WEBrick::AccessLog::COMBINED_LOG_FORMAT] ],
        :AccessLog => [ [$stdout, "> %h %U %b"] ],
        :DoNotReverseLookup => true,
    })

    s.mount_proc("/add") do |req, res|
        #p [req.peeraddr, req.query, req.query_string]
        # XXX: if you want auth, you can use query_string
        q = req.query
        if q["id"] && q["temperature"]
            if !reject_unknown || id2name[q["id"]]
                id = id2name.fetch(q["id"], "{#{q["id"]}}")
                t = q["temperature"].to_f
                tempdata.set(id, t, Time.now)
                res.body = "yup: #{id} -> #{t}.\n"
            else
                res.body = "nope (unknown id).\n"
            end
        else
            res.body = "nope (missing params).\n"
        end
    end

    s.mount_proc("/avgtemp") do |req, res|
        res['Content-Type'] = 'text/plain; charset=utf-8'
        res.body = if ag = tempdata.get_average
            "#{"%.01f °C" % ag}"
        else
            "N/A"
        end
        res
    end

    s.mount_proc("/dashtemp") do |req, res|
        # FIXME: implement this fully
        res['Content-Type'] = 'text/plain; charset=utf-8'
        res.body = if ag = tempdata.get_average
            "#{"%.01f °C" % ag}"
        else
            "-40.00 N/A"
        end
        res
    end

    s.mount_proc("/favicon.ico") do |req, res|
        res['Content-Type'] = 'image/gif'
        res.body = "47494638396110001000800100983cb8ffffff21f904010a0001002c000000001000100000021e8c8fa9cbed1f004052a6190dd694e76679d0376e90f998a852ade30b1f05003b".scan(/../).map { |x| x.to_i(16).chr }.join
        res
    end

    s.mount_proc("/apple-touch-icon-120x120.png") do |req, res|
        res['Content-Type'] = 'image/png'
        res.body = [
            # {{{
            "89504e470d0a1a0a0000000d4948445200000078000000780806000000396436",
            "d200000006624b474400ff00ff00ffa0bda793000000097048597300000b1300",
            "000b1301009a9c180000000774494d4507e30407092b185e9e03450000001d69",
            "545874436f6d6d656e7400000000004372656174656420776974682047494d50",
            "642e65070000094d4944415478daed9d6f7054d519877fefdddd242b0624946c",
            "da0e30adb12a423b100221596c241d247f48512b1faa580a15d8209152a69556",
            "f03265aa58076a0c04680798b1b56dd0402104061b88e36e2048a0082d744a05",
            "917148400502e6cfee9eb71f84198761cfee66ef2e59fa3e33f9b4f7bef7ec79",
            "ee39e73d676fce05044110044110044110044110044110044110044110044110",
            "044110044110044110921bea0b85f85de1d601a97ec7249051468c0718e40221",
            "13e02bc46863c259301ac1c1fab6e683ff3261725faac46af78e7b0cd8ca0ca0",
            "9081af02ec02280bcc7e22bac8e00bc4785f815b6104f654bc5b7ef4ff42704d",
            "7edd6018ce5f01a8209023a293985b15057f51e12d6bbc95653787d73a5c77dd",
            "398b0c6301807ba33997c14798796357f0caba85fba775dd96826bf277cc8261",
            "5b45407a6fce67e61dc19eaea79e79ef914f132a1626b9f2731f01d95e24c2b7",
            "6289c5e033acf0cbf6e69637e2d52b255cf0ec9c75f6d169435e06193f8d3516",
            "03fff5434da9f4961c4f44d9abb2ab521cae7baa89e8696b23f39f82f68e39f3",
            "9aa65d4d6ac1264cca728f7b1da0272cab1ae64b7ee2f1f1965c9dbb25c3969a",
            "f626811e8a477c661c057f5ee4697ef4bc95718d440a76b9c72db6522e0010d1",
            "8014d0b69579b503e355ee97726afbdb53d3de8997dc2fbe0746c270be5d9dbb",
            "25232905d7e4373c0460799caa27fb0e7bff4df1ea7506a4a5bf01d08828c656",
            "66c679303e6370c4632b81be634b75fe6d76ce3a7b52093661120c7a994014a6",
            "bb3d05c00c1217f9036aa46295c7084e07f35b115454f95a77fd77adef75729f",
            "20a2d2881226564bfc0135f270e799148f6f72e65cdfe40cffb9ffa42956798a",
            "d532803f8e60cc748f720e7b21a9c6e0d5ee86c76c30ded41da3a05e6ab7b79b",
            "66d38cee9bc618bf738ccd401d8886686e9096365fcb78ab32527378ad232b23",
            "fd34405fd3155db1fa757bd7472bccd6399dda78859b5233fdae4506680908a9",
            "ba1e002af8a0a7b9cc9b1482d716ecdc0ea2b29035c46a5985afc40c9be88cdf",
            "31d466330e10c815ea981ea8e156255c6bdc0ddf37606cd534db6ee6e00f3dcd",
            "a575d10d57f56e22fb3610066a6ed6437b7c1b723763b3ead35df4cabcda3426",
            "9aa8e9978f07da4efe269258cfec2b3da3144fd71d63e7f0dd69c495c3f413fd",
            "11eae7d1ca05004f739957411533739726791c5d943f6b7a9f1f83531de9f904",
            "dca1b953e7559eacec8934debce692b799d1a8c946275932e71dfbd6d74154a2",
            "5b8d3ad4f5d19adec6aff095b410f17ccd214d3d863ad0e70513f350cd424547",
            "5bf381a6e8278dc13f87fe8c8659516ebbc3f9035dfd3063e5fad6398158aed1",
            "e8ddb8018cc337dc386d4af193e7bcfb275a31d4d8e32f985ca1467a627ebf57",
            "091153aba605675934bf1eadeb9b03d4d110eb353663b32ac48c8536d8f60250",
            "00afe9b6773fbfa069eaa5a4992631f15da15b309dea4dcc2058b7fedcdf2c34",
            "6d16147c94266fd857e99d76c18afa99e72b6d6260b9422077aeb778be957213",
            "d282017ca6a9c56ff626a00d94a119d32f994d6630a6e951e1a654f2f3fda126",
            "194c3868650579bc9397c4abf213b1d0d1aee906479830a39eaab18d72359d6b",
            "5bac051ee4cf1c01a290373f2b9c449210ff244be1435d779ae91e3b219a788f",
            "e371c300cdd40cfaa7632db38de9be30898508be4ea7bab28f81cf43d795511d",
            "cdda6b91fbc73301e4858e87dd16dc9503b439800a9e12c1d758b87f5a1731ef",
            "d164bd2347a70d5b1449ac570bb60f61d00add313dc43167b70443fb10821130",
            "2e8ae02fdff1c49bc2d4e88b35ee9d4bcde1b5211fdb593d7ee79854d87da44f",
            "b05a3ef51e3811bb60d60aee50573b93457022b2689cf71ea873158c3ba49b5b",
            "1268996b60fa9335f90d1b83cc5e866ab7d9a81fd8b897408f82f018c2fc1a05",
            "e6c556fcd0a060a4ebeefcae4e248de0843dd1b1c65d5f64c0fef7f84db8b97e",
            "aeaf788a15a1d616ecda08c28c9b5f06418f6fb23d590427ec07ff0a6f592394",
            "5a1a27b91f5ce90accb07071c6a96912dd482212fac8ceb9e603cbc1f88bc561",
            "2f3307cb17b54ef924215f82994570084c987ca8ebc3e9ccea358beafa943fa0",
            "0a3ccd65ff8470eb0503c0fad639018fafa49299e780f94a0c7277f9a963ecfc",
            "fd25c744631f127c1d8faf787d57c07f37b37a8dc1fec8cde23007f9618fafb8",
            "d8aa05ffdb995b9a0d2e68296f0750b9c65dbf14caf63088ca087800c42e0606",
            "83719588da987116ac1ad916a86ff71e3ad6d7fe37490487cfb02f02f8ebb53f",
            "e176e8a205112c886041048b6041040b225810c182081644b0208205112c8205",
            "112c886041040b22b84f41442238d91d327586fe8c534470f21bbea269c176dd",
            "ff5089e02480810edde7694e38457032a3582b38dde8278293bb05935630a504",
            "0688e0a49e5ae80533d9bf218293b9873694768b0683295b0427313df69e2361",
            "e6c2960a9e9db3cede9bdd8644702f59d034f5d2b5bdab6fee17c8b1f27aa3d3",
            "863eeb2a18b7fbd582ed434470e2d0b4622a782567fb202b2eb26a425d1613bd",
            "4044df4b25c7b1b5f9bb7e64656b16c1217b61fa87aedefa398d622bae93c6ce",
            "155f7ab5507f18d894e5cedbba6a425d96088ee7542910d06ec7446c2c88754f",
            "ccd513764e24d05337f9a8dcc9ce636bf21ba689e038d1b6ffe041661cd534f1",
            "1c977fecdc5ecbcddb719f4d91e635073488c8783ed6177488e010983019c4bf",
            "0fd391bfb23a7f4779b4b16bf2ea736d76e31ddd96fe0094523c33d63da94954",
            "86a63a774b863dc5f9b1ee051a0014839774063a56867b0f615576558a2333fb",
            "67205a4a4469da21827985c757fc5cccb984680cd3dadc0dbf251861b75a64e6",
            "53045a1f40cfb60b8e43ffbebea5715576558add953d0a40b141f4749837b87c",
            "110bbcf770e79949b1b65e111cc9585958dbcf08f43f42c0dd519ca600be00c0",
            "c64046b8f745dd60f7740f5dceb56aff11111c0155ee86fb53d8f085193363cf",
            "dc994f31058b2abc6596ed662b495604547a4b8e0739f810a0ddfb3a36b9e013",
            "6c743f68a55c111c05f39a4b8ff4e0f21806ef8d43d37ddddff3c9d88a77a79e",
            "b57cc146d445397d1a5eeb7065dc391f6c2c26c2576214fb01433de7f1956e8e",
            "577945706fc7e5b17f4c7738329e25224f2499f10d625b99f90ffef6931ba279",
            "299808be350b2234383ff7db061993014c20200b40264099202866be08d00500",
            "4708eabd609077cfdb5f7a426a4e100441100441100441100441100441100441",
            "1004411004411004411004411004411084db9fff01a1a28be945cc247c000000",
            "0049454e44ae426082",
            # }}}
        ].join.scan(/../).map { |x| x.to_i(16).chr }.join
        res
    end

    s.mount_proc("/") do |req, res|
        res['Content-Type'] = 'text/html; charset=utf-8'
        out = []
        out << <<-EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Temperature</title>
<link rel="shortcut icon" type="image/png" href="/apple-touch-icon-120x120.png" />
<meta name="viewport" content="width=device-width">
<style>
body { background-color: #eee; }
.widget {
    display: inline-block;
    box-sizing: content-box;
    min-width: 15em;
    min-height: 5em;
    padding: 1em;
    border-radius: 6px;
    background-color: #fff;
    box-shadow: 0 0 15px #ddd;
    margin: 0.5em;
}
.degree { font-size: 4em; color: gold; }
.name { font-size: 1em; color: purple; font-weight: bold; }
.ts { font-size: 1em; color: #cbcbcb; }
</style>
</head>
<body>
        EOF
        out.last.strip!

        def widget(temp, name, time="")
            [
                "<div class='widget'>",
                "<span class='name'>#{name}</span>",
                (time.empty? ? "" : "<span class='ts'>(#{time})</span>") + "<br/>",
                "<span class='degree'>#{temp}</span>",
                "</div>",
            ].join("\n")
        end
        tempdata.get_all.sort.each do |name, (val,ts)|
            out << widget("#{"%.01f" % val}°", name.capitalize, "#{timeconv(Time.now.to_f - ts.to_f)} ago")
        end
        if ag = tempdata.get_average
            out << widget("#{"%.01f°" % ag}", "Average")
        else
            out << widget("N/A", "Average")
        end
        out << "</body>\n</html>"
        res.body = out.join("\n")
        res
    end

    s.start
end

threads.map(&:join)
