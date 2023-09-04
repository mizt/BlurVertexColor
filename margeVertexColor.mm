#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <vector>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		
		NSString *src = [NSString stringWithContentsOfFile:@"./random.obj" encoding:NSUTF8StringEncoding error:nil];
		NSArray *lines = [src componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
		
		NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
		
		std::vector<float> v;
		
		for(int k=0; k<[lines count]; k++) {
			
			NSArray *arr = [lines[k] componentsSeparatedByCharactersInSet:whitespaces];
			if([arr count]>0) {
				if([arr[0] isEqualToString:@"v"]) {
					v.push_back([arr[1] doubleValue]);
					v.push_back([arr[2] doubleValue]);
					v.push_back([arr[3] doubleValue]);
					v.push_back([arr[4] doubleValue]);
					v.push_back([arr[5] doubleValue]);
					v.push_back([arr[6] doubleValue]);
				}
			}
		}
		
		unsigned int length = v.size()/6;
		
		unsigned int *use = new unsigned int[length];
		for(int n=0; n<length; n++) use[n] = false;
		std::vector<std::vector<int>> indices;
		
		for(int n=0; n<length; n++) {
			
			float x = v[n*6+0];
			float y = v[n*6+1];
			float z = v[n*6+2];
			
			if(!use[n]) {
				
				use[n] = true;
				indices.push_back({});
				indices[indices.size()-1].push_back(n);
				
				for(int k=n; k<length; k++) {
					
					if(x==v[k*6+0]&&y==v[k*6+1]&&z==v[k*6+2]) {
						use[k] = true;
						indices[indices.size()-1].push_back(k);
					}
				}
			}
		}
		
		for(int n=0; n<indices.size(); n++) {

			float r = 0;
			float g = 0;
			float b = 0;

			for(int k=0; k<indices[n].size(); k++) {
				unsigned int addr = indices[n][k]*6+3;
				r+=v[addr+0];
				g+=v[addr+1];
				b+=v[addr+2];
			}
			
			r/=indices[n].size();
			g/=indices[n].size();
			b/=indices[n].size();
			
			for(int k=0; k<indices[n].size(); k++) {
				
				unsigned int addr = indices[n][k]*6+3;
				
				v[addr+0] = r;
				v[addr+1] = g;
				v[addr+2] = b;
			}
		}
		
		NSMutableString *obj = [NSMutableString stringWithString:@""];
		
		for(int n=0; n<length; n++) {
			[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f %04f %0.4f %0.4f %0.4f\n",v[n*6+0],v[n*6+1],v[n*6+2],v[n*6+3],v[n*6+4],v[n*6+5]]];
		} 
		
		for(int n=0; n<length/6; n++) {
			[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",1+n*6+0,1+n*6+1,1+n*6+2]];
			[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",1+n*6+3,1+n*6+4,1+n*6+5]];
		} 
		
		[obj writeToFile:@"marge.obj" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}