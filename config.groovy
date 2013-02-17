vertxVersion = '1.3.0.final'
jenvVersion = '0.0.1'
environments {
	dev {
		jenvService = 'http://localhost:8080'
	}
	test {
		jenvService = 'http://test.jvmtool.net'
	}
	prod {
		jenvService = 'http://get.jvmtool.net'
	}
}
