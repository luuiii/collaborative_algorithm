State : IdentityDictionary {
	classvar defaultVals;
	var server;

	*new {|s|
		^super.new.init(s);
  }

	init {|s|
		server = s;
	}

  *initClass {
		defaultVals = IdentityDictionary.newFrom([
			\pitch, 1,
			\count, 0
		]);
  }

	initKey { |name|
		if(this.at(name).isNil, {
			this.put(name, IdentityDictionary.new);
		})
	}

	getVal { |chain, key|
		this.initKey(chain);
		^this.at(chain).at(key) ? defaultVals.at(key);
  }

	setVal { |chain, key, value|
		this.initKey(chain);
		^this.at(chain).put(key, value);
  }

	update { |chain, key, value|
		server.sendMsg(\update_state, chain, key, value);
	}

  recordPassing { |chain|
		var currentCount;
		this.initKey(chain);
		currentCount = this.getVal(chain, \count);
		^this.setVal(chain, \count, currentCount + 1);
  }
}


