vertxVersion = '1.3.0.final'
jenvVersion = '0.0.1'
environments {
	dev {
		gvmService = 'http://localhost:8080'
	}
	test {
		gvmService = 'http://test.jvmtool.net'
	}
	prod {
		gvmService = 'http://get.jvmtool.net'
	}
}
